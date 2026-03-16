import { Request, Response, NextFunction } from 'express';
import { getFirebaseAuth } from '../services/firebase.service';
import { SupabaseUserService } from '../services/supabase-user.service';
import Logger from '../utils/logger';

const logger = new Logger('AUTH');

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

    // Look up Supabase user by Firebase UID to get the actual UUID
    const supabaseUser = await SupabaseUserService.getUserByFirebaseUid(decodedToken.uid);
    if (!supabaseUser) {
      return res.status(404).json({
        success: false,
        error: 'User not found in database',
      });
    }

    req.user = {
      firebaseUid: decodedToken.uid,
      userId: supabaseUser.id,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      customClaims: decodedToken.custom_claims,
    };

    // Set both firebaseUid and userId (Supabase UUID)
    req.userId = supabaseUser.id;
    req.firebaseUid = decodedToken.uid;

    console.log(`[AuthMiddleware] User authenticated: ${decodedToken.uid} -> ${supabaseUser.id}`);
    next();
  } catch (error: any) {
    console.error('[AuthMiddleware] Authentication error:', error.message);
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
