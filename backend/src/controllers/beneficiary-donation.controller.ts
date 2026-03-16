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
}
