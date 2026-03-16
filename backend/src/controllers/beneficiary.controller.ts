import { Request, Response, NextFunction } from 'express';
import { BeneficiaryService } from '../services/beneficiary.service';
import { NotFoundError, ValidationError } from '../utils/errors';
import Joi from 'joi';

const createBeneficiaryDetailsSchema = Joi.object({
  full_name: Joi.string().required().min(3).max(255),
  nic: Joi.string().required().min(5).max(20),
  address: Joi.string().required().min(10).max(500),
  bank_account_holder_name: Joi.string().required().min(3).max(255),
  bank_account_number: Joi.string().required().min(8).max(20),
  bank_name: Joi.string().required().min(3).max(100),
  bank_code: Joi.string().required().min(2).max(10),
});

const updateBeneficiaryDetailsSchema = Joi.object({
  full_name: Joi.string().optional().min(3).max(255),
  address: Joi.string().optional().min(10).max(500),
  bank_account_holder_name: Joi.string().optional().min(3).max(255),
  bank_account_number: Joi.string().optional().min(8).max(20),
  bank_name: Joi.string().optional().min(3).max(100),
  bank_code: Joi.string().optional().min(2).max(10),
});

const createCampaignSchema = Joi.object({
  full_name: Joi.string().required().min(3).max(255),
  title: Joi.string().required().min(5).max(255),
  description: Joi.string().required().min(20).max(2000),
  target_amount: Joi.number().required().positive(),
  image_url: Joi.string().uri().optional().allow(null, ''),
});

const updateCampaignSchema = Joi.object({
  title: Joi.string().optional().min(5).max(255),
  description: Joi.string().optional().min(20).max(2000),
  target_amount: Joi.number().optional().positive(),
  image_url: Joi.string().uri().optional().allow(null, ''),
  status: Joi.string().optional().valid('active', 'completed', 'cancelled'),
});

export class BeneficiaryController {
  /**
   * Get beneficiary details
   */
  static async getBeneficiaryDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new Error('User not authenticated');
      }

      const details = await BeneficiaryService.getBeneficiaryDetails(userId);

      if (!details) {
        throw new NotFoundError('Beneficiary details');
      }

      res.json({
        success: true,
        data: details,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Create beneficiary details
   */
  static async createBeneficiaryDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = createBeneficiaryDetailsSchema.validate(req.body, {
        abortEarly: false,
      });

      if (error) {
        const errorDetails = error.details.map(e => ({
          field: e.path.join('.'),
          message: e.message,
        }));
        console.error('Validation errors:', errorDetails);
        throw new ValidationError(
          `Validation failed: ${error.details.map(e => e.message).join('; ')}`
        );
      }

      const userId = req.userId;
      if (!userId) {
        throw new Error('User not authenticated');
      }

      console.log('[BeneficiaryController] Creating beneficiary details for user:', userId);
      const details = await BeneficiaryService.createBeneficiaryDetails(userId, value);

      res.status(201).json({
        success: true,
        data: details,
        message: 'Beneficiary details created successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update beneficiary details
   */
  static async updateBeneficiaryDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = updateBeneficiaryDetailsSchema.validate(req.body, {
        abortEarly: false,
      });

      if (error) {
        const errorDetails = error.details.map(e => ({
          field: e.path.join('.'),
          message: e.message,
        }));
        console.error('Validation errors:', errorDetails);
        throw new ValidationError(
          `Validation failed: ${error.details.map(e => e.message).join('; ')}`
        );
      }

      const userId = req.userId;
      if (!userId) {
        throw new Error('User not authenticated');
      }

      console.log('[BeneficiaryController] Updating beneficiary details for user:', userId);
      const details = await BeneficiaryService.updateBeneficiaryDetails(userId, value);

      res.json({
        success: true,
        data: details,
        message: 'Beneficiary details updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get all campaigns for beneficiary
   */
  static async getBeneficiaryCampaigns(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new Error('User not authenticated');
      }

      const campaigns = await BeneficiaryService.getBeneficiaryCampaigns(userId);

      res.json({
        success: true,
        data: campaigns,
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

      const campaign = await BeneficiaryService.getCampaignById(campaignId);

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
   * Create beneficiary campaign
   */
  static async createCampaign(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = createCampaignSchema.validate(req.body, {
        abortEarly: false,
      });

      if (error) {
        const errorDetails = error.details.map(e => ({
          field: e.path.join('.'),
          message: e.message,
        }));
        console.error('Validation errors:', errorDetails);
        throw new ValidationError(
          `Validation failed: ${error.details.map(e => e.message).join('; ')}`
        );
      }

      const userId = req.userId;
      if (!userId) {
        throw new Error('User not authenticated');
      }

      console.log('[BeneficiaryController] Creating campaign for user:', userId);
      const campaign = await BeneficiaryService.createCampaign(userId, value);

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
   * Update beneficiary campaign
   */
  static async updateCampaign(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = updateCampaignSchema.validate(req.body, {
        abortEarly: false,
      });

      if (error) {
        const errorDetails = error.details.map(e => ({
          field: e.path.join('.'),
          message: e.message,
        }));
        console.error('Validation errors:', errorDetails);
        throw new ValidationError(
          `Validation failed: ${error.details.map(e => e.message).join('; ')}`
        );
      }

      const { campaignId } = req.params;

      console.log('[BeneficiaryController] Updating campaign:', campaignId);
      const campaign = await BeneficiaryService.updateCampaign(campaignId, value);

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
   * Delete beneficiary campaign
   */
  static async deleteCampaign(req: Request, res: Response, next: NextFunction) {
    try {
      const { campaignId } = req.params;

      console.log('[BeneficiaryController] Deleting campaign:', campaignId);
      await BeneficiaryService.deleteCampaign(campaignId);

      res.json({
        success: true,
        message: 'Campaign deleted successfully',
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

      const progress = await BeneficiaryService.getCampaignProgress(campaignId);

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
   * Get all beneficiary campaigns (public/filtered)
   */
  static async getAllCampaigns(req: Request, res: Response, next: NextFunction) {
    try {
      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const filters = {
        status: req.query.status as string,
        searchQuery: req.query.search as string,
      };

      const result = await BeneficiaryService.getAllCampaigns(page, limit, filters);

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
}
