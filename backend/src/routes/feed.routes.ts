import { Router } from 'express';
import { FeedController } from '../controllers/feed.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

// Public feed listing (auth optional for liked_by_me enrichment)
router.get('/', FeedController.getFeedPosts);

// Create new community post
router.post('/', authenticateToken, FeedController.createFeedPost);

// Toggle like
router.post('/:postId/like', authenticateToken, FeedController.toggleLike);

export default router;
