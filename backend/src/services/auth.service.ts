import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { getDatabase } from './database.service';
import { getFirebaseAuth } from './firebase.service';
import { SupabaseUserService } from './supabase-user.service';
import { User, LoginRequest, RegisterRequest, AuthResponse } from '../types';
import { v4 as uuidv4 } from 'uuid';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const JWT_EXPIRATION = process.env.JWT_EXPIRATION || '7d';

export class AuthService {
  /**
   * Register a new user
   * Flow: Firebase Auth → Supabase users table + wallet creation
   */
  static async register(data: RegisterRequest): Promise<AuthResponse> {
    // Always generate a UUID for the database ID
    const userId = uuidv4();
    
    // Use Firebase UID if provided, otherwise will be created by backend
    let firebaseUID = data.firebase_uid;

    // Step 1: Check if email exists in Firebase first
    console.log('[AuthService] Checking if email exists in Firebase:', data.email);
    const firebaseAuth = getFirebaseAuth();
    
    // Only check/create Firebase user if not provided by Flutter
    if (!data.firebase_uid) {
      try {
        const existingFirebaseUser = await firebaseAuth.getUserByEmail(data.email);
        if (existingFirebaseUser) {
          console.log('[AuthService] Email already exists in Firebase');
          throw new Error('Email already registered');
        }
      } catch (error: any) {
        if (error.code !== 'auth/user-not-found') {
          // Any error other than "not found" is a real error
          console.error('[AuthService] Firebase check failed:', error);
          throw error;
        }
        // 'auth/user-not-found' is expected and means we can proceed
      }

      // Step 2: Create Firebase user only if not provided
      try {
        const firebaseUser = await firebaseAuth.createUser({
          uid: userId,
          email: data.email,
          password: data.password,
          displayName: data.full_name,
        });
        firebaseUID = firebaseUser.uid;
        console.log('[AuthService] Firebase user created:', firebaseUID);
      } catch (error) {
        console.error('[AuthService] Firebase creation failed:', error);
        throw error;
      }
    } else {
      console.log('[AuthService] Using provided Firebase UID:', firebaseUID);
    }

    // Step 3: Check if email exists in Supabase
    console.log('[AuthService] Checking if email exists in Supabase:', data.email);
    const existingSupabaseUser = await SupabaseUserService.userExists(data.email);
    if (existingSupabaseUser) {
      throw new Error('Email already registered');
    }

    // Step 4: Sync user to Supabase (public.users table)
    let supabaseUser;
    try {
      supabaseUser = await SupabaseUserService.createUser(firebaseUID, data, userId);
      console.log('[AuthService] User synced to Supabase:', userId);

      // Step 5: Create wallet for new user in Supabase
      // Volunteers (stored as `charity` role in this app) do not need wallets.
      if (data.role === 'donor' || data.role === 'beneficiary') {
        await SupabaseUserService.createWallet(userId);
        console.log('[AuthService] Wallet created for user:', userId);
      } else {
        console.log('[AuthService] Skipping wallet creation for role:', data.role);
      }
    } catch (error: any) {
      console.error('[AuthService] Supabase sync failed:', error.message);
      throw new Error(`User registration failed: ${error.message}`);
    }

    // Step 6: Generate tokens
    const tokens = this.generateTokens({
      id: userId,
      email: data.email,
      full_name: data.full_name,
      role: data.role,
    });

    return {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      user: {
        id: userId,
        email: data.email,
        full_name: data.full_name,
        role: data.role,
        verified: false,
        email_verified: false,
        is_active: true,
      },
    };
  }

  /**
   * Login user
   */
  static async login(data: LoginRequest): Promise<AuthResponse> {
    const db = getDatabase();

    // Find user
    const user = await db('users').where('email', data.email).first();
    if (!user) {
      throw new Error('Invalid email or password');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(data.password, user.password_hash);
    if (!isPasswordValid) {
      throw new Error('Invalid email or password');
    }

    // Update last_login in local database
    await db('users').where('user_id', user.user_id).update({
      last_login: new Date(),
    });

    // Update last_login in Supabase (non-blocking, don't fail login if it fails)
    try {
      await SupabaseUserService.updateLastLogin(user.user_id);
    } catch (error) {
      console.warn('[AuthService] Failed to update last login in Supabase:', error);
      // Don't fail login if Supabase update fails
    }

    // Generate tokens
    const tokens = this.generateTokens(user);

    return {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      user: this.formatUser(user),
    };
  }

  /**
   * Generate access and refresh tokens
   */
  static generateTokens(user: User) {
    const payload = {
      user_id: user.user_id,
      email: user.email,
      role: user.role,
    };

    const access_token = jwt.sign(payload, JWT_SECRET, {
      expiresIn: JWT_EXPIRATION,
    });

    const refresh_token = jwt.sign(payload, JWT_SECRET, {
      expiresIn: '30d',
    });

    return { access_token, refresh_token };
  }

  /**
   * Verify token
   */
  static verifyToken(token: string) {
    try {
      return jwt.verify(token, JWT_SECRET);
    } catch (error) {
      return null;
    }
  }

  /**
   * Format user response
   */
  static formatUser(user: any): User {
    const { password_hash, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  /**
   * Request password reset
   */
  static async requestPasswordReset(email: string): Promise<void> {
    const db = getDatabase();
    const user = await db('users').where('email', email).first();
    
    if (!user) {
      // Don't reveal if email exists
      return;
    }

    // Generate reset token
    const resetToken = jwt.sign({ user_id: user.user_id }, JWT_SECRET, {
      expiresIn: '1h',
    });

    // Store reset token (in production, use a separate table)
    // TODO: Implement password reset token storage

    // Send email with reset link
    // TODO: Implement email service
  }

  /**
   * Reset password with token
   */
  static async resetPassword(token: string, newPassword: string): Promise<void> {
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as any;
      const db = getDatabase();

      const hashedPassword = await bcrypt.hash(newPassword, 10);
      await db('users').where('user_id', decoded.user_id).update({
        password_hash: hashedPassword,
      });
    } catch (error) {
      throw new Error('Invalid or expired reset token');
    }
  }

  /**
   * Verify email
   */
  static async verifyEmail(userId: string): Promise<void> {
    const db = getDatabase();
    await db('users').where('user_id', userId).update({
      email_verified: true,
    });
  }
}
