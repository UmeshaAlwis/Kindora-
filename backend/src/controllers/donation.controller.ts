import { Request, Response, NextFunction } from 'express';
import { DonationService } from '../services/donation.service';
import { WalletService } from '../services/wallet.service';
import { StripeService } from '../services/stripe.service';
import { NotFoundError, ValidationError, UnauthorizedError } from '../utils/errors';
import Joi from 'joi';

const createDonationSchema = Joi.object({
  campaign_id: Joi.string().uuid().required(),
  charity_id: Joi.string().uuid().optional(),
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

  /**
   * Create Stripe payment intent
   */
  static async createStripePaymentIntent(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const { campaign_id, amount, donor_email, donor_name } = req.body;

      if (!campaign_id || !amount || !donor_email) {
        throw new ValidationError('campaign_id, amount, and donor_email are required');
      }

      // Amount in cents for Stripe
      const amountInCents = Math.round(amount * 100);

      const paymentResult = await StripeService.createPaymentIntent({
        amount: amountInCents,
        currency: 'USD', // Change to your currency
        description: `Donation to campaign: ${campaign_id}`,
        customerEmail: donor_email,
        customerName: donor_name || 'Anonymous',
        successUrl: `${process.env.PAYMENT_SUCCESS_URL}?session_id={CHECKOUT_SESSION_ID}`,
        cancelUrl: process.env.PAYMENT_CANCEL_URL || 'http://localhost:3000/cancel',
        metadata: {
          donor_id: userId,
          campaign_id,
          donation_type: 'one-time',
        },
      });

      if (!paymentResult.success) {
        throw new Error(paymentResult.error);
      }

      res.json({
        success: true,
        data: {
          clientSecret: paymentResult.clientSecret,
          paymentIntentId: paymentResult.paymentIntentId,
          publishableKey: StripeService.getPublishableKey(),
        },
        message: 'Payment intent created. Use clientSecret for payment.',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Confirm Stripe payment
   */
  static async confirmStripePayment(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const { payment_intent_id, campaign_id, amount, is_anonymous, message } = req.body;

      if (!payment_intent_id || !campaign_id || !amount) {
        throw new ValidationError('payment_intent_id, campaign_id, and amount are required');
      }

      // Verify payment with Stripe
      const paymentIntent = await StripeService.retrievePaymentIntent(payment_intent_id);

      if (paymentIntent.status !== 'succeeded') {
        throw new ValidationError(`Payment status is ${paymentIntent.status}, expected succeeded`);
      }

      // Create donation record
      const donation = await DonationService.createDonation(userId, {
        campaign_id,
        amount,
        payment_method: 'stripe',
        donation_type: 'one-time',
        message,
        is_anonymous: is_anonymous || false,
      });

      // Update donation with transaction ID
      await DonationService.updateDonationStatus((donation as any).donation_id, 'success', payment_intent_id);

      res.json({
        success: true,
        data: donation,
        message: 'Donation successful!',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Handle Stripe webhook
   */
  static async handleStripeWebhook(req: Request, res: Response, next: NextFunction) {
    try {
      const signature = req.headers['stripe-signature'] as string;
      const body = req.body;

      const event = StripeService.verifyWebhookSignature(body, signature);

      if (!event) {
        throw new ValidationError('Invalid webhook signature');
      }

      switch (event.type) {
        case 'payment_intent.succeeded':
          const paymentIntent = event.data.object;
          console.log(`Payment succeeded: ${paymentIntent.id}`);
          // Handle payment success - update donation status if needed
          break;

        case 'payment_intent.payment_failed':
          const failedPayment = event.data.object;
          console.log(`Payment failed: ${failedPayment.id}`);
          // Handle payment failure
          break;

        default:
          console.log(`Unhandled event type: ${event.type}`);
      }

      res.json({ received: true });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get Stripe publishable key
   */
  static async getStripePublishableKey(req: Request, res: Response, next: NextFunction) {
    try {
      const publishableKey = StripeService.getPublishableKey();

      res.json({
        success: true,
        data: { publishableKey },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Initialize wallet for new user
   */
  static async initializeWallet(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId || req.body.user_id;
      if (!userId) {
        throw new UnauthorizedError();
      }

      // Wallet is auto-created during registration, just return existing or create if missing
      const balance = await WalletService.getWalletBalance(userId);

      res.status(201).json({
        success: true,
        data: {
          user_id: userId,
          balance,
          message: 'Wallet initialized or already exists',
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get wallet details
   */
  static async getWalletDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const balance = await WalletService.getWalletBalance(userId);

      res.json({
        success: true,
        data: {
          user_id: userId,
          balance,
          currency: 'LKR',
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Top up wallet balance
   */
  static async topUpWallet(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const { amount, payment_method } = req.body;

      if (!amount || amount <= 0) {
        throw new ValidationError('Valid amount is required');
      }

      // Add amount to wallet (dummy/mock implementation until Stripe is ready)
      const updatedWallet = await WalletService.addToWallet(
        userId,
        amount,
        `topup_${Date.now()}`
      );

      res.json({
        success: true,
        data: {
          user_id: userId,
          amount_added: amount,
          new_balance: updatedWallet.balance ?? 0,
          total_recharged: updatedWallet.total_recharged ?? amount,
          message: 'Wallet top-up successful (Demo mode)',
        },
        message: 'Wallet top-up successful',
      });
    } catch (error) {
      next(error);
    }
  }
}
