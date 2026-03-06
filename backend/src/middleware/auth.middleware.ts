import { Request, Response, NextFunction } from 'express';
import { getFirebaseAuth } from '../services/firebase.service';
import Logger from '../utils/logger';

const logger = new Logger('AuthMiddleware');

declare global {
  namespace Express {
    interface Request {
      user?: any;
      userId?: string;
      firebaseUid?: string;
    }
  }
}

export async function authenticateToken(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    // Skip authentication in development if SKIP_AUTH is enabled
    if (process.env.SKIP_AUTH === 'true' && process.env.NODE_ENV === 'development') {
      logger.warn('⚠️  Authentication skipped (SKIP_AUTH=true)');
      
      // Mock user for testing
      req.user = {
        firebaseUid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        customClaims: { role: 'donor' },
      };
      req.userId = 'test-user-id';
      req.firebaseUid = 'test-user-id';
      
      return next();
    }

    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Access token required',
      });
    }

    // Verify Firebase ID token
    const firebaseAuth = getFirebaseAuth();
    const decodedToken = await firebaseAuth.verifyIdToken(token);

    if (!decodedToken) {
      return res.status(403).json({
        success: false,
        error: 'Invalid or expired token',
      });
    }

    // Get user details from Firebase
    const firebaseUser = await firebaseAuth.getUser(decodedToken.uid);

    req.user = {
      firebaseUid: decodedToken.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      customClaims: decodedToken.custom_claims,
    };

    req.userId = decodedToken.uid;
    req.firebaseUid = decodedToken.uid;

    logger.info(`User authenticated: ${decodedToken.uid}`);
    next();
  } catch (error: any) {
    logger.error('Authentication error:', error.message);
    return res.status(403).json({
      success: false,
      error: error.message || 'Invalid or expired token',
    });
  }
}

export function authorizeRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    // Get role from Firebase custom claims
    const customClaims = (req.user as any)?.customClaims || {};
    const userRole = customClaims.role;

    if (!userRole || !roles.includes(userRole)) {
      return res.status(403).json({
        success: false,
        error: 'Insufficient permissions',
      });
    }

    next();
  };
}
