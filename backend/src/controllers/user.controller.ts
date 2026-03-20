import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/user.service';
import { NotFoundError, UnauthorizedError, ValidationError } from '../utils/errors';

export class UserController {
  /**
   * Get user profile
   */
  static async getProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const user = await UserService.getUserById(userId);
      if (!user) {
        throw new NotFoundError('User');
      }

      res.json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update user profile
   */
  static async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const updates = req.body;

      // Prevent sensitive field updates
      delete updates.password_hash;
      delete updates.email;
      delete updates.role;

      const user = await UserService.updateProfile(userId, updates);

      res.json({
        success: true,
        data: user,
        message: 'Profile updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user stats
   */
  static async getUserStats(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const stats = await UserService.getUserStats(userId);

      res.json({
        success: true,
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Follow charity
   */
  static async followCharity(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      const { charityId } = req.params;

      if (!userId) {
        throw new UnauthorizedError();
      }

      const follow = await UserService.followCharity(userId, charityId);

      res.status(201).json({
        success: true,
        data: follow,
        message: 'Charity followed',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Unfollow charity
   */
  static async unfollowCharity(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      const { charityId } = req.params;

      if (!userId) {
        throw new UnauthorizedError();
      }

      await UserService.unfollowCharity(userId, charityId);

      res.json({
        success: true,
        message: 'Charity unfollowed',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get followed charities
   */
  static async getFollowedCharities(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      const charities = await UserService.getFollowedCharities(userId);

      res.json({
        success: true,
        data: charities,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Deactivate account
   */
  static async deactivateAccount(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) {
        throw new UnauthorizedError();
      }

      await UserService.deactivateUser(userId);

      res.json({
        success: true,
        message: 'Account deactivated successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}
