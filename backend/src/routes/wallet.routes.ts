import { Router } from 'express';
import { DonationController } from '../controllers/donation.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

// Wallet balance and transactions
router.get('/balance', authenticateToken, DonationController.getWalletBalance);
router.get('/transactions', authenticateToken, DonationController.getWalletTransactions);
router.get('/details', authenticateToken, DonationController.getWalletDetails);

// Wallet initialization and top-up
router.post('/initialize', authenticateToken, DonationController.initializeWallet);
router.post('/topup', authenticateToken, DonationController.topUpWallet);

export default router;
