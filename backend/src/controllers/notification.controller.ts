import { Request, Response, NextFunction } from 'express';
import { NotificationService } from '../services/notification.service';
import { NotFoundError } from '../utils/errors';
import Joi from 'joi';

export class NotificationController {
  static async getNotifications(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) throw new NotFoundError('User');

      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);
      const offset = (page - 1) * limit;

      const notifications = await NotificationService.getUserNotifications({
        userId,
        limit,
        offset,
      });

      const unreadCount = await NotificationService.getUnreadCount(userId);

      res.json({
        success: true,
        data: {
          notifications,
          unread_count: unreadCount,
          page,
          limit,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  static async getUnreadCount(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) throw new NotFoundError('User');

      const unreadCount = await NotificationService.getUnreadCount(userId);
      res.json({
        success: true,
        data: { unread_count: unreadCount },
      });
    } catch (error) {
      next(error);
    }
  }

  static async markAllRead(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) throw new NotFoundError('User');

      await NotificationService.markAllRead(userId);

      res.json({
        success: true,
        message: 'Notifications marked as read',
      });
    } catch (error) {
      next(error);
    }
  }

  static async markReadById(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.userId;
      if (!userId) throw new NotFoundError('User');

      const schema = Joi.object({
        notificationId: Joi.string().uuid().required(),
      });

      const { notificationId } = schema.validate(req.params).value;
      await NotificationService.markReadById({ userId, notificationId });

      res.json({
        success: true,
        message: 'Notification marked as read',
      });
    } catch (error) {
      next(error);
    }
  }
}

