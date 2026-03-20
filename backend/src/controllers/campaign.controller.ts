import { Request, Response, NextFunction } from 'express';
import { CampaignService } from '../services/campaign.service';
import { NotFoundError, ValidationError } from '../utils/errors';
import Joi from 'joi';

const createCampaignSchema = Joi.object({
  title: Joi.string().required().min(3).max(255),
  campaigner_name: Joi.string().optional(),
  category: Joi.string().optional(),
  campaign_category: Joi.string().optional(),
  needs_volunteers: Joi.boolean().optional(),
  target_amount: Joi.number().required().positive(),
  image_url: Joi.string().uri().optional().allow(null, ''),
  start_date: Joi.date().optional(),
  // These fields are sent from Flutter but not stored in campaigns table
  description: Joi.string().optional(),
  beneficiary_details: Joi.string().optional(),
  beneficiary_location: Joi.string().optional(),
  gallery_urls: Joi.array().items(Joi.string().uri()).optional(),
  end_date: Joi.date().optional(),
  charity_id: Joi.string().optional(),
});

export class CampaignController {
  /**
   * Get all campaigns
   */
  static async getCampaigns(req: Request, res: Response, next: NextFunction) {
    try {
      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const filters = {
        status: req.query.status as string,
        category: req.query.category as string,
        charityId: req.query.charityId as string,
        searchQuery: req.query.search as string,
        sortBy: req.query.sortBy as string,
      };

      const result = await CampaignService.getCampaigns(page, limit, filters);

      res.json({
        success: true,
        data: result.campaigns,
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
   * Get campaign by ID
   */
  static async getCampaignById(req: Request, res: Response, next: NextFunction) {
    try {
      const { campaignId } = req.params;

      const campaign = await CampaignService.getCampaignById(campaignId);
      if (!campaign) {
        throw new NotFoundError('Campaign');
      }

      res.json({
        success: true,
        data: campaign,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Create campaign (charity only)
   */
  static async createCampaign(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = createCampaignSchema.validate(req.body, { abortEarly: false });
      if (error) {
        const errorDetails = error.details.map(e => ({
          field: e.path.join('.'),
          message: e.message,
        }));
        console.error('Validation errors:', errorDetails);
        console.error('Request body:', req.body);
        throw new ValidationError(`Validation failed: ${error.details.map(e => e.message).join('; ')}`);
      }

      // Get user ID from authenticated request
      const userId = req.userId;
      if (!userId) {
        throw new Error('User not authenticated');
      }

      console.log('[CampaignController] Creating campaign for user:', userId);
      const campaign = await CampaignService.createCampaign(userId, value);

      res.status(201).json({
        success: true,
        data: campaign,
        message: 'Campaign created successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update campaign
   */
  static async updateCampaign(req: Request, res: Response, next: NextFunction) {
    try {
      const { campaignId } = req.params;

      const campaign = await CampaignService.updateCampaign(campaignId, req.body);

      res.json({
        success: true,
        data: campaign,
        message: 'Campaign updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get campaign progress
   */
  static async getCampaignProgress(req: Request, res: Response, next: NextFunction) {
    try {
      const { campaignId } = req.params;

      const progress = await CampaignService.getCampaignProgress(campaignId);
      if (!progress) {
        throw new NotFoundError('Campaign');
      }

      res.json({
        success: true,
        data: progress,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get recommended campaigns for user
   */
  static async getRecommended(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      const limit = Math.min(50, parseInt(req.query.limit as string) || 10);

      const campaigns = await CampaignService.getRecommendedCampaigns(userId, limit);

      res.json({
        success: true,
        data: campaigns,
      });
    } catch (error) {
      next(error);
    }
  }
}
