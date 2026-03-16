import { Router, Request, Response, NextFunction } from 'express';
import { BeneficiaryDonationController } from '../controllers/beneficiary-donation.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

/**
 * POST /api/beneficiary-donations
 * Create a new beneficiary donation
 */
router.post('/', authenticateToken, (req: Request, res: Response, next: NextFunction) => {
  BeneficiaryDonationController.createBeneficiaryDonation(req, res, next);
});

/**
 * GET /api/beneficiary-donations/history
 * Get beneficiary donation history for current user
 */
router.get('/history', authenticateToken, (req: Request, res: Response, next: NextFunction) => {
  BeneficiaryDonationController.getBeneficiaryDonationHistory(req, res, next);
});

/**
 * GET /api/beneficiary-donations/total
 * Get total donated to beneficiary campaigns by current user
 */
router.get('/total', authenticateToken, (req: Request, res: Response, next: NextFunction) => {
  BeneficiaryDonationController.getTotalBeneficiaryDonated(req, res, next);
});

/**
 * GET /api/beneficiary-donations/campaign/:beneficiary_campaign_id/raised
 * Get total raised for a specific beneficiary campaign
 */
router.get('/campaign/:beneficiary_campaign_id/raised', (req: Request, res: Response, next: NextFunction) => {
  BeneficiaryDonationController.getTotalRaisedForBeneficiaryCampaign(req, res, next);
});

export default router;
