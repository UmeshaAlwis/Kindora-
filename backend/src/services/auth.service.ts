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
   * Flow: Firebase Auth → Supabase users table → Local database (for backward compatibility)
   */
  static async register(data: RegisterRequest): Promise<AuthResponse> {
    const db = getDatabase();
    const userId = uuidv4();

    // Step 1: Check if email exists in Supabase
    const existingSupabaseUser = await SupabaseUserService.userExists(data.email);
    if (existingSupabaseUser) {
      throw new Error('Email already registered');
    }

    // Step 2: Check if email exists in local database
    const existingUser = await db('users').where('email', data.email).first();
    if (existingUser) {
      throw new Error('Email already registered');
    }

    // Step 3: Create Firebase user first
    let firebaseUID = '';
    try {
      const firebaseAuth = getFirebaseAuth();
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

    // Step 4: Sync user to Supabase (public.users table)
    try {
      await SupabaseUserService.createUser(firebaseUID, data, userId);
      console.log('[AuthService] User synced to Supabase:', userId);

      // Step 5: Create wallet for new user in Supabase
      await SupabaseUserService.createWallet(userId);
      console.log('[AuthService] Wallet created for user:', userId);
    } catch (error: any) {
      console.error('[AuthService] Supabase sync failed:', error.message);
      throw new Error(`User registration failed: ${error.message}`);
    }

    // Step 6: Hash password for local database (backward compatibility)
    const hashedPassword = await bcrypt.hash(data.password, 10);

    // Step 7: Create user in local database
    let user;
    try {
      user = await db('users').insert({
        user_id: userId,
        email: data.email,
        password_hash: hashedPassword,
        full_name: data.full_name,
        role: data.role,
        phone_number: data.phone_number,
        email_verified: false,
        is_active: true,
      }).returning('*');
      console.log('[AuthService] User created in local database:', userId);
    } catch (error) {
      console.error('[AuthService] Local database creation failed:', error);
      // Note: User already exists in Firebase and Supabase, but not in local DB
      // This is acceptable - user can still authenticate via Firebase
      throw error;
    }

    // Step 8: Initialize gamification for donors
    if (data.role === 'donor') {
      try {
        await db('gamification').insert({
          user_id: userId,
          donor_level: 'bronze',
          total_points: 0,
        });
        console.log('[AuthService] Gamification initialized for donor:', userId);
      } catch (error) {
        console.error('[AuthService] Gamification init failed:', error);
        // Don't fail registration if gamification fails
      }
    }

    // Step 9: Generate tokens
    const tokens = this.generateTokens(user[0]);

    return {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      user: this.formatUser(user[0]),
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
