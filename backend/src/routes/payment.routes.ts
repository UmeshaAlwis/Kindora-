import express, { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import PayHereService, { PayHereNotificationPayload } from '../services/payhere.service';
import { DonationService } from '../services/donation.service';
import { getDatabase } from '../services/database.service';
import { authenticateToken } from '../middleware/auth.middleware';
import Logger from '../utils/logger';

const router: Router = express.Router();
const logger = new Logger('PaymentRoutes');

/**
 * POST /payments/initiate-donation
 * Initiate a donation with PayHere
 */
router.post('/initiate-donation', authenticateToken, async (req: Request, res: Response) => {
  try {
    const { campaignId, amount, message, isAnonymous } = req.body;
    const userId = (req as any).user.userId;

    // Validate input
    if (!campaignId || !amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid campaign ID or amount',
      });
    }

    const db = getDatabase();

    // Verify campaign exists
    const campaign = await db('campaigns').where({ campaign_id: campaignId }).first();
    if (!campaign) {
      return res.status(404).json({
        success: false,
        error: 'Campaign not found',
      });
    }

    // Verify user exists
    const user = await db('users').where({ user_id: userId }).first();
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    // Create donation record with pending status
    const donationId = uuidv4();
    const donation = await db('donations')
      .insert({
        donation_id: donationId,
        donor_id: userId,
        campaign_id: campaignId,
        amount,
        payment_method: 'payhere',
        donation_type: 'one-time',
        message: message || null,
        is_anonymous: isAnonymous || false,
        status: 'pending',
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    // Initiate PayHere payment
    const paymentRequest = {
      orderId: donationId,
      amount,
      currency: 'LKR',
      merchantId: process.env.PAYHERE_MERCHANT_ID || '',
      returnUrl: `${process.env.API_URL}/payments/payhere/return`,
      cancelUrl: `${process.env.API_URL}/payments/payhere/cancel`,
      notifyUrl: `${process.env.API_URL}/payments/payhere/notify`,
      firstName: user.full_name.split(' ')[0],
      lastName: user.full_name.split(' ')[1] || '',
      email: user.email,
      phone: user.phone_number || '+94000000000',
      address: user.location || 'Not provided',
      city: user.location || 'Not provided',
      country: 'LK',
      customOne: campaignId,
      customTwo: userId,
      customThree: donationId,
    };

    const paymentResponse = await PayHereService.initiatePayment(paymentRequest);

    if (!paymentResponse.success) {
      // Update donation status to failed
      await DonationService.updateDonationStatus(donationId, 'failed');
      return res.status(400).json({
        success: false,
        error: paymentResponse.error || 'Failed to initiate payment',
      });
    }

    logger.info(`Payment initiated for donation: ${donationId}`);

    return res.json({
      success: true,
      data: {
        donationId,
        paymentUrl: paymentResponse.paymentUrl,
        amount,
      },
    });
  } catch (error) {
    logger.error('Error initiating donation payment:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Internal server error',
    });
  }
});

/**
 * POST /payments/payhere/notify
 * PayHere payment notification webhook
 */
router.post('/payhere/notify', async (req: Request, res: Response) => {
  try {
    const notification = req.body as PayHereNotificationPayload;

    // Verify notification
    const isValid = PayHereService.verifyNotification(notification);

    if (!isValid) {
      logger.warn(`Invalid PayHere notification received`);
      return res.status(400).json({ success: false });
    }

    const db = getDatabase();
    const donationId = notification.order_id;

    // Map PayHere status codes to our status
    // Status codes: 2 = Completed, -2 = Failed, -1 = Cancelled
    const statusMap: Record<number, string> = {
      2: 'success',
      '-2': 'failed',
      '-1': 'refunded',
    };

    const donationStatus = statusMap[notification.status_code as any] || 'failed';

    // Update donation status
    const donation = await DonationService.updateDonationStatus(
      donationId,
      donationStatus,
      notification.payment_id
    );

    // Create payment transaction record
    await db('payment_transactions').insert({
      transaction_id: uuidv4(),
      donation_id: donationId,
      user_id: (donation as any).donor_id,
      amount: notification.payhere_amount,
      currency: notification.payhere_currency,
      payment_gateway: 'payhere',
      gateway_reference_id: notification.payment_id,
      gateway_response: JSON.stringify(notification),
      status: donationStatus,
      created_at: new Date(),
      updated_at: new Date(),
    });

    logger.info(`Payment notification processed for donation: ${donationId}, status: ${donationStatus}`);

    // PayHere requires 200 response
    return res.status(200).json({ success: true });
  } catch (error) {
    logger.error('Error processing PayHere notification:', error);
    res.status(500).json({ success: false });
  }
});

/**
 * GET /payments/payhere/return
 * PayHere return URL (user redirected after payment)
 */
router.get('/payhere/return', async (req: Request, res: Response) => {
  try {
    const { order_id } = req.query;
    const db = getDatabase();

    if (!order_id) {
      return res.status(400).send('Invalid request');
    }

    // Get donation
    const donation = await db('donations')
      .where({ donation_id: order_id })
      .first();

    if (!donation) {
      return res.status(404).send('Donation not found');
    }

    // Redirect to frontend with donation status
    const redirectUrl = `${process.env.FRONTEND_URL}/donation-success?donationId=${order_id}&status=${donation.status}`;
    return res.redirect(redirectUrl);
  } catch (error) {
    logger.error('Error in PayHere return:', error);
    res.status(500).send('Internal server error');
  }
});

/**
 * GET /payments/payhere/cancel
 * PayHere cancel URL (user cancelled payment)
 */
router.get('/payhere/cancel', async (req: Request, res: Response) => {
  try {
    const { order_id } = req.query;
    const db = getDatabase();

    if (!order_id) {
      return res.status(400).send('Invalid request');
    }

    // Update donation status
    await DonationService.updateDonationStatus(order_id as string, 'failed');

    // Redirect to frontend
    const redirectUrl = `${process.env.FRONTEND_URL}/donation-cancelled?donationId=${order_id}`;
    return res.redirect(redirectUrl);
  } catch (error) {
    logger.error('Error in PayHere cancel:', error);
    res.status(500).send('Internal server error');
  }
});

/**
 * GET /payments/status/:donationId
 * Check payment status
 */
router.get('/status/:donationId', authenticateToken, async (req: Request, res: Response) => {
  try {
    const { donationId } = req.params;
    const userId = (req as any).user.userId;
    const db = getDatabase();

    // Get donation
    const donation = await db('donations')
      .where({ donation_id: donationId })
      .first();

    if (!donation) {
      return res.status(404).json({
        success: false,
        error: 'Donation not found',
      });
    }

    // Verify user is the donor
    if (donation.donor_id !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Unauthorized',
      });
    }

    // Get payment transaction
    const transaction = await db('payment_transactions')
      .where({ donation_id: donationId })
      .first();

    return res.json({
      success: true,
      data: {
        donation,
        transaction,
      },
    });
  } catch (error) {
    logger.error('Error checking payment status:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Internal server error',
    });
  }
});

export default router;
