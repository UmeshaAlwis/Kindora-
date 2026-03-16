import { Router } from 'express';
import { BeneficiaryController } from '../controllers/beneficiary.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

/**
 * Beneficiary Profile Routes
 */

/**
 * GET /beneficiary/profile - Get beneficiary details (protected)
 */
router.get('/profile', authenticateToken, BeneficiaryController.getBeneficiaryDetails);

/**
 * POST /beneficiary/profile - Create beneficiary details (protected)
 */
router.post('/profile', authenticateToken, BeneficiaryController.createBeneficiaryDetails);

/**
 * PUT /beneficiary/profile - Update beneficiary details (protected)
 */
router.put('/profile', authenticateToken, BeneficiaryController.updateBeneficiaryDetails);

/**
 * Beneficiary Campaign Routes
 */

/**
 * GET /beneficiary/campaigns - Get all beneficiary campaigns for user (protected)
 */
router.get('/campaigns', authenticateToken, BeneficiaryController.getBeneficiaryCampaigns);

/**
 * GET /beneficiary/campaigns/all - Get all beneficiary campaigns (public/paginated)
 */
router.get('/campaigns/all', BeneficiaryController.getAllCampaigns);

/**
 * POST /beneficiary/campaigns - Create new beneficiary campaign (protected)
 */
router.post('/campaigns', authenticateToken, BeneficiaryController.createCampaign);

/**
 * GET /beneficiary/campaigns/:campaignId - Get campaign details
 */
router.get('/campaigns/:campaignId', BeneficiaryController.getCampaignById);

/**
 * PUT /beneficiary/campaigns/:campaignId - Update campaign (protected)
 */
router.put('/campaigns/:campaignId', authenticateToken, BeneficiaryController.updateCampaign);

/**
 * DELETE /beneficiary/campaigns/:campaignId - Delete campaign (protected)
 */
router.delete('/campaigns/:campaignId', authenticateToken, BeneficiaryController.deleteCampaign);

/**
 * GET /beneficiary/campaigns/:campaignId/progress - Get campaign progress
 */
router.get('/campaigns/:campaignId/progress', BeneficiaryController.getCampaignProgress);

export default router;
