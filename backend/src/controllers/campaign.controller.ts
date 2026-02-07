import { Request, Response, NextFunction } from 'express';
import { CampaignService } from '../services/campaign.service';
import { NotFoundError, ValidationError } from '../utils/errors';
import Joi from 'joi';

const createCampaignSchema = Joi.object({
  title: Joi.string().required().min(3).max(255),
  description: Joi.string().required().min(10),
  category: Joi.string().required(),
  target_amount: Joi.number().required().positive(),
  beneficiary_details: Joi.string(),
  beneficiary_location: Joi.string(),
  image_url: Joi.string().uri(),
  gallery_urls: Joi.array().items(Joi.string().uri()),
  end_date: Joi.date(),
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
      const { error, value } = createCampaignSchema.validate(req.body);
      if (error) {
        throw new ValidationError(error.message);
      }

      // TODO: Get charity ID from user
      const charityId = req.body.charityId;

      const campaign = await CampaignService.createCampaign(charityId, value);

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
