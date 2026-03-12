import { SupabaseClient } from './supabase.service';
import { RegisterRequest } from '../types';
import { v4 as uuidv4 } from 'uuid';

/**
 * SupabaseUserService
 * Handles syncing Firebase users to Supabase database
 * This ensures user profiles are stored in Supabase for RLS and data queries
 */
export class SupabaseUserService {
  private static supabase = new SupabaseClient();

  /**
   * Create user in Supabase after Firebase registration
   * This syncs Firebase Auth with Supabase public.users table
   *
   * @param firebaseUid - The Firebase UID from Firebase Auth
   * @param data - Registration data
   * @param userId - Optional UUID for the user (if not provided, generates new one)
   * @returns Created user data
   */
  static async createUser(
    firebaseUid: string,
    data: RegisterRequest,
    userId?: string
  ): Promise<any> {
    try {
      const userUUID = userId || uuidv4();

      const userData = {
        id: userUUID,
        firebase_uid: firebaseUid,
        email: data.email,
        full_name: data.full_name,
        phone_number: data.phone_number || null,
        role: data.role || 'donor',
        email_verified: false,
        verified: false,
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      console.log('[SupabaseUserService] Creating user:', {
        id: userUUID,
        email: data.email,
        role: data.role,
      });

      const response = await this.supabase.insert('users', userData);

      console.log('[SupabaseUserService] User created successfully:', {
        id: userUUID,
        email: data.email,
      });

      return response;
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to create user:', error.message);
      throw new Error(`Failed to sync user to Supabase: ${error.message}`);
    }
  }

  /**
   * Get user by Firebase UID
   *
   * @param firebaseUid - Firebase UID
   * @returns User data or null if not found
   */
  static async getUserByFirebaseUid(firebaseUid: string): Promise<any> {
    try {
      const users = await this.supabase.select('users', {
        filters: { firebase_uid: firebaseUid },
      });

      return users[0] || null;
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to get user:', error.message);
      return null;
    }
  }

  /**
   * Get user by email
   *
   * @param email - User email
   * @returns User data or null if not found
   */
  static async getUserByEmail(email: string): Promise<any> {
    try {
      const users = await this.supabase.select('users', {
        filters: { email: email },
      });

      return users[0] || null;
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to get user by email:', error.message);
      return null;
    }
  }

  /**
   * Update user profile
   *
   * @param userId - User UUID
   * @param updates - Fields to update
   * @returns Updated user data
   */
  static async updateUser(userId: string, updates: Record<string, any>): Promise<any> {
    try {
      console.log('[SupabaseUserService] Updating user:', userId, updates);

      const updateData = {
        ...updates,
        updated_at: new Date().toISOString(),
      };

      const response = await this.supabase.update('users', updateData, { id: userId });

      return response;
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to update user:', error.message);
      throw error;
    }
  }

  /**
   * Update user last login timestamp
   *
   * @param userId - User UUID
   */
  static async updateLastLogin(userId: string): Promise<void> {
    try {
      await this.updateUser(userId, {
        last_login: new Date().toISOString(),
      });
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to update last login:', error.message);
    }
  }

  /**
   * Create wallet for new user (auto-called after user registration)
   *
   * @param userId - User UUID
   */
  static async createWallet(userId: string): Promise<any> {
    try {
      console.log('[SupabaseUserService] Creating wallet for user:', userId);

      const walletData = {
        wallet_id: uuidv4(),
        user_id: userId,
        balance: 0.00,
        total_recharged: 0.00,
        total_spent: 0.00,
      };

      const response = await this.supabase.insert('wallets', walletData);

      console.log('[SupabaseUserService] Wallet created successfully for user:', userId);

      return response;
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to create wallet:', error.message);
      // Don't throw - wallet might be created by trigger, just log
      return null;
    }
  }

  /**
   * Verify email address for user
   *
   * @param userId - User UUID
   */
  static async verifyEmail(userId: string): Promise<void> {
    try {
      await this.updateUser(userId, {
        email_verified: true,
        verified: true,
      });
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to verify email:', error.message);
    }
  }

  /**
   * Deactivate user account
   *
   * @param userId - User UUID
   */
  static async deactivateUser(userId: string): Promise<void> {
    try {
      await this.updateUser(userId, {
        is_active: false,
      });
    } catch (error: any) {
      console.error('[SupabaseUserService] Failed to deactivate user:', error.message);
    }
  }

  /**
   * Check if user exists by email
   *
   * @param email - User email
   * @returns true if user exists, false otherwise
   */
  static async userExists(email: string): Promise<boolean> {
    try {
      const user = await this.getUserByEmail(email);
      return !!user;
    } catch {
      return false;
    }
  }
}
