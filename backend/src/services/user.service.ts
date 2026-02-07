import { getDatabase } from './database.service';
import { User } from '../types';
import { v4 as uuidv4 } from 'uuid';

export class UserService {
  /**
   * Get user by ID
   */
  static async getUserById(userId: string): Promise<User | null> {
    const db = getDatabase();
    const user = await db('users').where('user_id', userId).first();
    return user || null;
  }

  /**
   * Get user by email
   */
  static async getUserByEmail(email: string): Promise<User | null> {
    const db = getDatabase();
    const user = await db('users').where('email', email).first();
    return user || null;
  }

  /**
   * Update user profile
   */
  static async updateProfile(userId: string, data: Partial<User>) {
    const db = getDatabase();
    const updates = { ...data, updated_at: new Date() };

    const user = await db('users')
      .where('user_id', userId)
      .update(updates)
      .returning('*');

    return user[0];
  }

  /**
   * Get all users (admin only)
   */
  static async getAllUsers(
    page: number = 1,
    limit: number = 20,
    role?: string
  ) {
    const db = getDatabase();
    let query = db('users');

    if (role) {
      query = query.where('role', role);
    }

    const total = await query.count('* as count').first();
    const users = await query
      .offset((page - 1) * limit)
      .limit(limit)
      .select('*');

    return {
      users,
      total: total?.count || 0,
      page,
      limit,
      pages: Math.ceil((total?.count || 0) / limit),
    };
  }

  /**
   * Deactivate user account
   */
  static async deactivateUser(userId: string) {
    const db = getDatabase();
    await db('users').where('user_id', userId).update({
      is_active: false,
      updated_at: new Date(),
    });
  }

  /**
   * Get user statistics
   */
  static async getUserStats(userId: string) {
    const db = getDatabase();

    // Get donation stats
    const donationStats = await db('donations')
      .where('donor_id', userId)
      .select(
        db.raw('COUNT(*) as count'),
        db.raw('SUM(amount) as total_amount'),
        'status'
      )
      .groupBy('status');

    // Get gamification stats
    const gamification = await db('gamification')
      .where('user_id', userId)
      .first();

    // Get campaigns followed or involved
    const campaigns = await db('donations')
      .distinct('campaign_id')
      .where('donor_id', userId)
      .count('* as campaign_count');

    return {
      donations: donationStats,
      gamification,
      campaignCount: campaigns[0]?.campaign_count || 0,
    };
  }

  /**
   * Follow charity
   */
  static async followCharity(userId: string, charityId: string) {
    const db = getDatabase();

    // Check if already following
    const existing = await db('follows')
      .where({ user_id: userId, charity_id: charityId })
      .first();

    if (existing) {
      return existing;
    }

    const follow = await db('follows')
      .insert({
        follow_id: uuidv4(),
        user_id: userId,
        charity_id: charityId,
        created_at: new Date(),
      })
      .returning('*');

    return follow[0];
  }

  /**
   * Unfollow charity
   */
  static async unfollowCharity(userId: string, charityId: string) {
    const db = getDatabase();
    await db('follows')
      .where({ user_id: userId, charity_id: charityId })
      .delete();
  }

  /**
   * Get followed charities
   */
  static async getFollowedCharities(userId: string) {
    const db = getDatabase();
    return await db('charities')
      .join('follows', 'charities.charity_id', 'follows.charity_id')
      .where('follows.user_id', userId)
      .select('charities.*')
      .orderBy('follows.created_at', 'desc');
  }
}
