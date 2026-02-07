import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { getDatabase } from './database.service';
import { getFirebaseAuth } from './firebase.service';
import { User, LoginRequest, RegisterRequest, AuthResponse } from '../types';
import { v4 as uuidv4 } from 'uuid';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const JWT_EXPIRATION = process.env.JWT_EXPIRATION || '7d';

export class AuthService {
  /**
   * Register a new user
   */
  static async register(data: RegisterRequest): Promise<AuthResponse> {
    const db = getDatabase();

    // Check if email exists
    const existingUser = await db('users').where('email', data.email).first();
    if (existingUser) {
      throw new Error('Email already registered');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 10);

    // Create user in database
    const userId = uuidv4();
    const user = await db('users').insert({
      user_id: userId,
      email: data.email,
      password_hash: hashedPassword,
      full_name: data.full_name,
      role: data.role,
      phone_number: data.phone_number,
      email_verified: false,
      is_active: true,
    }).returning('*');

    // Create Firebase user
    try {
      const firebaseAuth = getFirebaseAuth();
      await firebaseAuth.createUser({
        uid: userId,
        email: data.email,
        password: data.password,
        displayName: data.full_name,
      });
    } catch (error) {
      // If Firebase fails, delete database user
      await db('users').where('user_id', userId).delete();
      throw error;
    }

    // Initialize gamification for donors
    if (data.role === 'donor') {
      await db('gamification').insert({
        user_id: userId,
        donor_level: 'bronze',
        total_points: 0,
      });
    }

    // Generate tokens
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

    // Update last_login
    await db('users').where('user_id', user.user_id).update({
      last_login: new Date(),
    });

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
