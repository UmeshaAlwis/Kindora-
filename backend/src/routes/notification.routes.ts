import { Router } from 'express';
import { authenticateToken } from '../middleware/auth.middleware';
import { NotificationController } from '../controllers/notification.controller';

const router = Router();

router.get('/', authenticateToken, NotificationController.getNotifications);
router.get('/unread-count', authenticateToken, NotificationController.getUnreadCount);
router.patch('/mark-read-all', authenticateToken, NotificationController.markAllRead);
router.patch('/:notificationId/read', authenticateToken, NotificationController.markReadById);

export default router;

