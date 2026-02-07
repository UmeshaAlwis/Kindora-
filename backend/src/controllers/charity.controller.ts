import { Request, Response, NextFunction } from 'express';
import { CharityService } from '../services/charity.service';
import { NotFoundError, ValidationError, ForbiddenError } from '../utils/errors';
import Joi from 'joi';

const registerCharitySchema = Joi.object({
  name: Joi.string().required().min(3),
  description: Joi.string(),
  category: Joi.string().required(),
  registration_number: Joi.string().required().unique(),
  contact_info: Joi.string(),
  website_url: Joi.string().uri(),
  documents_url: Joi.array().items(Joi.string().uri()),
});

export class CharityController {
  /**
   * Get all charities
   */
  static async getCharities(req: Request, res: Response, next: NextFunction) {
    try {
      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const filters = {
        status: req.query.status as string,
        category: req.query.category as string,
        searchQuery: req.query.search as string,
      };

      const result = await CharityService.getCharities(page, limit, filters);

      res.json({
        success: true,
        data: result.charities,
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
   * Get charity by ID
   */
  static async getCharityById(req: Request, res: Response, next: NextFunction) {
    try {
      const { charityId } = req.params;

      const charity = await CharityService.getCharityById(charityId);
      if (!charity) {
        throw new NotFoundError('Charity');
      }

      res.json({
        success: true,
        data: charity,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Register as charity
   */
  static async registerCharity(req: Request, res: Response, next: NextFunction) {
    try {
      const { error, value } = registerCharitySchema.validate(req.body);
      if (error) {
        throw new ValidationError(error.message);
      }

      const userId = req.userId;

      const charity = await CharityService.registerCharity(userId, value);

      res.status(201).json({
        success: true,
        data: charity,
        message: 'Charity registered. Awaiting verification.',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update charity profile
   */
  static async updateCharityProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const { charityId } = req.params;

      // TODO: Verify ownership or admin role

      const charity = await CharityService.updateCharityProfile(charityId, req.body);

      res.json({
        success: true,
        data: charity,
        message: 'Charity profile updated',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get charity statistics
   */
  static async getCharityStats(req: Request, res: Response, next: NextFunction) {
    try {
      const { charityId } = req.params;

      const stats = await CharityService.getCharityStats(charityId);

      res.json({
        success: true,
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get top charities
   */
  static async getTopCharities(req: Request, res: Response, next: NextFunction) {
    try {
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const charities = await CharityService.getTopCharities(limit);

      res.json({
        success: true,
        data: charities,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Add impact story (charity only)
   */
  static async addImpactStory(req: Request, res: Response, next: NextFunction) {
    try {
      const { charityId } = req.params;
      const { story, image_url } = req.body;

      if (!story) {
        throw new ValidationError('Story is required');
      }

      // TODO: Verify charity ownership

      const charity = await CharityService.addImpactStory(charityId, story, image_url);

      res.status(201).json({
        success: true,
        data: charity,
        message: 'Impact story added',
      });
    } catch (error) {
      next(error);
    }
  }
}
