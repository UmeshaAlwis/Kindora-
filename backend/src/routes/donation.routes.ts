import { Router } from 'express';
import { DonationController } from '../controllers/donation.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

// Donation routes
router.post('/', authenticateToken, DonationController.createDonation);
router.get('/history', authenticateToken, DonationController.getDonationHistory);
router.get('/total', authenticateToken, DonationController.getTotalDonated);
router.get('/badges', authenticateToken, DonationController.getBadgeSummary);
router.post('/recurring', authenticateToken, DonationController.setupRecurring);
router.delete('/recurring/:donationId', authenticateToken, DonationController.cancelRecurring);
router.get('/campaign/:campaignId/stats', DonationController.getCampaignStats);

// Stripe Payment routes
router.post('/stripe/create-intent', authenticateToken, DonationController.createStripePaymentIntent);
router.post('/stripe/confirm-payment', authenticateToken, DonationController.confirmStripePayment);
router.post('/stripe/webhook', DonationController.handleStripeWebhook);
router.get('/stripe/publishable-key', DonationController.getStripePublishableKey);

// Wallet routes
router.get('/wallet/balance', authenticateToken, DonationController.getWalletBalance);
router.get('/wallet/transactions', authenticateToken, DonationController.getWalletTransactions);

// Legacy payment confirmation
router.post('/confirm-payment', DonationController.confirmPayment);

export default router;
