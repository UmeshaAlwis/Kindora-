import { Request, Response, NextFunction } from 'express';
import { DonationService } from '../services/donation.service';
import { NotFoundError, ValidationError, UnauthorizedError } from '../utils/errors';
import Joi from 'joi';

const createDonationSchema = Joi.object({
  campaign_id: Joi.string().uuid().required(),
  amount: Joi.number().required().positive().min(10).max(100000),
  payment_method: Joi.string()
    .valid('card', 'mobile_wallet', 'bank_transfer', 'crypto')
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

      const donation = await DonationService.createDonation(userId, value);

      // TODO: Integrate with PayHere payment gateway
      // For now, return donation ready for payment

      res.status(201).json({
        success: true,
        data: {
          ...donation,
          payment_url: 'https://payhere.lk/pay/...', // PayHere payment URL
        },
        message: 'Donation created. Proceed to payment.',
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
}
