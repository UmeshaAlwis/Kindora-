import { Request, Response, NextFunction } from 'express';
import { BeneficiaryDonationService } from '../services/beneficiary-donation.service';
import { WalletService } from '../services/wallet.service';
import { NotFoundError, ValidationError, UnauthorizedError } from '../utils/errors';
import Joi from 'joi';

const createBeneficiaryDonationSchema = Joi.object({
  beneficiary_campaign_id: Joi.string().uuid().required(),
  amount: Joi.number().required().positive().min(10).max(100000),
  payment_method: Joi.string()
    .valid('card', 'wallet', 'bank_transfer', 'stripe', 'payhere')
    .required(),
  donation_type: Joi.string().valid('one-time', 'recurring'),
  recurring_frequency: Joi.string().valid('daily', 'weekly', 'monthly', 'yearly'),
  recurring_end_date: Joi.date().iso().optional(),
  message: Joi.string().max(500),
  is_anonymous: Joi.boolean(),
  donor_name: Joi.string().max(255),
  donor_email: Joi.string().email().max(255),
  donor_phone: Joi.string().max(20),
});

export class BeneficiaryDonationController {
  /**
   * Create beneficiary donation
   */
  static async createBeneficiaryDonation(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = createBeneficiaryDonationSchema.validate(req.body);
      if (error) {
        throw new ValidationError(error.message);
      }

      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      // Recurring beneficiary donations currently support wallet only.
      // (Card/bank transfer recurring would require payment method tokens/subscriptions.)
      if (value.donation_type === 'recurring') {
        if (!value.recurring_frequency) {
          throw new ValidationError('recurring_frequency is required for recurring donations');
        }
        if (value.payment_method !== 'wallet') {
          throw new ValidationError('Recurring beneficiary donations are only supported with wallet payments');
        }
      }

      // Check wallet balance if wallet payment method is selected
      if (value.payment_method === 'wallet') {
        const balance = await WalletService.getWalletBalance(userId);
        if (balance < value.amount) {
          throw new ValidationError(
            `Insufficient wallet balance. Available: ${balance}, Required: ${value.amount}`
          );
        }
      }

      const donation = await BeneficiaryDonationService.createBeneficiaryDonation(userId, value);

      res.status(201).json({
        success: true,
        data: donation,
        message: value.payment_method === 'wallet'
          ? 'Beneficiary donation successful!'
          : 'Donation created. Proceed to payment.',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get beneficiary donation history
   */
  static async getBeneficiaryDonationHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const result = await BeneficiaryDonationService.getUserBeneficiaryDonationHistory(userId, page, limit);

      res.json({
        success: true,
        data: result.donations,
        total: result.total,
        page: result.page,
        limit: result.limit,
        pages: result.pages,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get total donated to beneficiary campaigns
   */
  static async getTotalBeneficiaryDonated(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const total = await BeneficiaryDonationService.getTotalBeneficiaryDonatedByUser(userId);

      res.json({
        success: true,
        data: { total_donated: total },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get total raised for a beneficiary campaign
   */
  static async getTotalRaisedForBeneficiaryCampaign(req: Request, res: Response, next: NextFunction) {
    try {
      const { beneficiary_campaign_id } = req.params;

      const total = await BeneficiaryDonationService.getTotalRaisedForBeneficiaryCampaign(
        beneficiary_campaign_id
      );

      res.json({
        success: true,
        data: { total_raised: total },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Card (non-stripe) payment for beneficiary campaigns:
   * create donation record (pending) then confirm to mark as completed.
   */
  static async createCardPaymentIntent(req: Request, res: Response, next: NextFunction) {
    try {
      const schema = Joi.object({
        beneficiary_campaign_id: Joi.string().uuid().required(),
        amount: Joi.number().required().positive().min(10).max(100000),
        donor_name: Joi.string().max(255).required(),
        donor_email: Joi.string().email().max(255).required(),
        donor_phone: Joi.string().max(20).optional(),
        message: Joi.string().allow('').max(500).optional(),
        is_anonymous: Joi.boolean().optional(),
      });

      const { error, value } = schema.validate(req.body);
      if (error) throw new ValidationError(error.message);

      const userId = req.userId;
      if (!userId) throw new UnauthorizedError();

      const donation = await BeneficiaryDonationService.createBeneficiaryDonation(userId, {
        beneficiary_campaign_id: value.beneficiary_campaign_id,
        amount: value.amount,
        payment_method: 'card',
        donation_type: 'one-time',
        donor_name: value.donor_name,
        donor_email: value.donor_email,
        donor_phone: value.donor_phone,
        message: value.message,
        is_anonymous: value.is_anonymous ?? false,
      });

      const donationId = donation?.id ?? donation?.[0]?.id;
      if (!donationId) throw new ValidationError('Failed to create card payment intent');

      res.status(200).json({
        success: true,
        data: {
          client_secret: donationId,
          donation_id: donationId,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  static async confirmCardPayment(req: Request, res: Response, next: NextFunction) {
    try {
      const schema = Joi.object({
        donation_id: Joi.string().uuid().required(),
        transaction_id: Joi.string().optional(),
      });

      const { error, value } = schema.validate(req.body);
      if (error) throw new ValidationError(error.message);

      const userId = req.userId;
      if (!userId) throw new UnauthorizedError();

      const updated = await BeneficiaryDonationService.updateBeneficiaryDonationStatus(
        value.donation_id,
        'completed',
        value.transaction_id ?? `card_txn_${Date.now()}`
      );

      if (updated && updated.user_id && updated.user_id !== userId) {
        throw new UnauthorizedError();
      }

      res.status(200).json({
        success: true,
        data: {
          donation: updated,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  static async cancelCardPayment(req: Request, res: Response, next: NextFunction) {
    try {
      const schema = Joi.object({
        donation_id: Joi.string().uuid().required(),
        transaction_id: Joi.string().optional(),
      });

      const { error, value } = schema.validate(req.body);
      if (error) throw new ValidationError(error.message);

      const userId = req.userId;
      if (!userId) throw new UnauthorizedError();

      const updated = await BeneficiaryDonationService.updateBeneficiaryDonationStatus(
        value.donation_id,
        'failed',
        value.transaction_id ?? `card_txn_${Date.now()}`
      );

      if (updated && updated.user_id && updated.user_id !== userId) {
        throw new UnauthorizedError();
      }

      res.status(200).json({
        success: true,
        data: {
          donation: updated,
        },
      });
    } catch (error) {
      next(error);
    }
  }
}
