import { Request, Response, NextFunction } from 'express';
import { DonationService } from '../services/donation.service';
import { WalletService } from '../services/wallet.service';
import { NotFoundError, ValidationError, UnauthorizedError } from '../utils/errors';
import Joi from 'joi';

const createDonationSchema = Joi.object({
  campaign_id: Joi.string().uuid().required(),
  amount: Joi.number().required().positive().min(10).max(100000),
  payment_method: Joi.string()
    .valid('card', 'wallet', 'bank_transfer', 'crypto')
    .required(),
  donation_type: Joi.string().valid('one-time', 'recurring'),
  recurring_frequency: Joi.string().valid('daily', 'weekly', 'monthly', 'yearly'),
  message: Joi.string().max(500),
  is_anonymous: Joi.boolean(),
});

export class DonationController {
  /**
   * Create donation
   */
  static async createDonation(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = createDonationSchema.validate(req.body);
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

      const donation = await DonationService.createDonation(userId, value);

      res.status(201).json({
        success: true,
        data: donation,
        message: value.payment_method === 'wallet' 
          ? 'Donation successful!' 
          : 'Donation created. Proceed to payment.',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get donation history
   */
  static async getDonationHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const result = await DonationService.getUserDonationHistory(userId, page, limit);

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
   * Get total donated by user
   */
  static async getTotalDonated(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const total = await DonationService.getTotalDonatedByUser(userId);

      res.json({
        success: true,
        data: { total_donated: total },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Setup recurring donation
   */
  static async setupRecurring(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const donation = await DonationService.setupRecurringDonation(userId, req.body);

      res.status(201).json({
        success: true,
        data: donation,
        message: 'Recurring donation setup. Proceed to confirm payment.',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Cancel recurring donation
   */
  static async cancelRecurring(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const { donationId } = req.params;

      // Verify ownership
      // TODO: Add verification

      await DonationService.cancelRecurringDonation(donationId);

      res.json({
        success: true,
        message: 'Recurring donation cancelled successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get campaign donation stats
   */
  static async getCampaignStats(req: Request, res: Response, next: NextFunction) {
    try {
      const { campaignId } = req.params;

      const stats = await DonationService.getCampaignDonationStats(campaignId);
      if (!stats) {
        throw new NotFoundError('Campaign');
      }

      res.json({
        success: true,
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Webhook for payment confirmation (PayHere)
   */
  static async confirmPayment(req: Request, res: Response, next: NextFunction) {
    try {
      const { donation_id, payment_id, status } = req.body;

      // Verify signature from PayHere
      // TODO: Implement PayHere signature verification

      if (status === 'success') {
        await DonationService.updateDonationStatus(donation_id, 'success', payment_id);

        // TODO: Send confirmation email
        // TODO: Send notification to charity
      } else {
        await DonationService.updateDonationStatus(donation_id, 'failed', payment_id);
      }

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user wallet balance
   */
  static async getWalletBalance(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const balance = await WalletService.getWalletBalance(userId);

      res.json({
        success: true,
        data: { balance },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get wallet transactions
   */
  static async getWalletTransactions(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const result = await WalletService.getWalletTransactions(userId, page, limit);

      res.json({
        success: true,
        data: result.transactions,
        total: result.total,
        page: result.page,
        limit: result.limit,
        pages: result.pages,
      });
    } catch (error) {
      next(error);
    }
  }
}
