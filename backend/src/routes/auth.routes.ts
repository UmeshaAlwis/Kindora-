import { Router, Request, Response } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

/**
 * POST /auth/register - Register a new user
 */
router.post('/register', AuthController.register);

/**
 * POST /auth/login - Login user
 */
router.post('/login', AuthController.login);

/**
 * POST /auth/refresh-token - Refresh access token
 */
router.post('/refresh-token', AuthController.refreshToken);

/**
 * POST /auth/request-password-reset - Request password reset
 */
router.post('/request-password-reset', AuthController.requestPasswordReset);

/**
 * POST /auth/reset-password - Reset password with token
 */
router.post('/reset-password', AuthController.resetPassword);

/**
 * GET /auth/verify-email/:userId - Verify email
 */
router.get('/verify-email/:userId', AuthController.verifyEmail);

/**
 * GET /auth/me - Get current user (protected)
 */
router.get('/me', authenticateToken, (req: Request, res: Response) => {
  res.json({
    success: true,
    data: req.user,
  });
});

export default router;
