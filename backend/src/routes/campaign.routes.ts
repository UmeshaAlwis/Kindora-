import { Router } from 'express';
import { CampaignController } from '../controllers/campaign.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

/**
 * GET /campaigns - Get all campaigns with filters
 */
router.get('/', CampaignController.getCampaigns);

/**
 * POST /campaigns - Create new campaign (protected)
 */
router.post('/', authenticateToken, CampaignController.createCampaign);

/**
 * GET /campaigns/:campaignId - Get campaign details
 */
router.get('/:campaignId', CampaignController.getCampaignById);

/**
 * PUT /campaigns/:campaignId - Update campaign (protected)
 */
router.put('/:campaignId', authenticateToken, CampaignController.updateCampaign);

/**
 * GET /campaigns/:campaignId/progress - Get campaign progress
 */
router.get('/:campaignId/progress', CampaignController.getCampaignProgress);

/**
 * GET /campaigns/recommended - Get recommended campaigns (protected)
 */
router.get('/user/recommended', authenticateToken, CampaignController.getRecommended);

export default router;
