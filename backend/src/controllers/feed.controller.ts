import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { FeedService } from '../services/feed.service';

const createPostSchema = Joi.object({
  content: Joi.string().allow('').max(3000),
  media_url: Joi.string().uri().optional().allow(null, ''),
  media_type: Joi.string().valid('none', 'image', 'video').optional(),
}).or('content', 'media_url');

export class FeedController {
  static async getFeedPosts(req: Request, res: Response, next: NextFunction) {
    try {
      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(50, parseInt(req.query.limit as string) || 20);
      const userId = req.userId;

      const result = await FeedService.getFeedPosts(page, limit, userId);
      res.json({
        success: true,
        data: result.posts,
        total: result.total,
        page: result.page,
        limit: result.limit,
        pages: result.pages,
      });
    } catch (error) {
      next(error);
    }
  }

  static async createFeedPost(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
      }

      const { error, value } = createPostSchema.validate(req.body, { abortEarly: false });
      if (error) {
        return res.status(400).json({
          success: false,
          error: error.details.map((e) => e.message).join('; '),
        });
      }

      const created = await FeedService.createFeedPost(userId, value);
      res.status(201).json({
        success: true,
        data: created,
        message: 'Post created successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  static async toggleLike(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
      }

      const { postId } = req.params;
      const result = await FeedService.toggleLike(postId, userId);

      res.json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}
