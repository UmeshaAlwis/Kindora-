import { Router } from 'express';
import { DonationController } from '../controllers/donation.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

// Donation routes
router.post('/', authenticateToken, DonationController.createDonation);
router.get('/history', authenticateToken, DonationController.getDonationHistory);
router.get('/total', authenticateToken, DonationController.getTotalDonated);
router.post('/recurring', authenticateToken, DonationController.setupRecurring);
router.delete('/recurring/:donationId', authenticateToken, DonationController.cancelRecurring);
router.get('/campaign/:campaignId/stats', DonationController.getCampaignStats);
router.post('/confirm-payment', DonationController.confirmPayment);

// Wallet routes
router.get('/wallet/balance', authenticateToken, DonationController.getWalletBalance);
router.get('/wallet/transactions', authenticateToken, DonationController.getWalletTransactions);

export default router;
