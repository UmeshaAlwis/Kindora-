import type { Knex } from 'knex';
import { getDatabase } from './database.service';
import { v4 as uuidv4 } from 'uuid';

function requireDb(): Knex {
  const db = getDatabase();
  if (db === null) {
    throw new Error('Database is not initialized');
  }
  return db;
}

export class CharityService {
  /**
   * Get all charities with filtering
   */
  static async getCharities(
    page: number = 1,
    limit: number = 20,
    filters: {
      status?: string;
      category?: string;
      searchQuery?: string;
    } = {}
  ) {
    const db = requireDb();
    let query = db('charities');

    if (filters.status) {
      query = query.where('verification_status', filters.status);
    }
    if (filters.category) {
      query = query.where('category', filters.category);
    }
    if (filters.searchQuery) {
      query = query.where('name', 'ilike', `%${filters.searchQuery}%`);
    }

    const totalRow = await query.clone().count('* as count').first();
    const totalCount = Number(totalRow?.count ?? 0) || 0;
    const charities = await query
      .offset((page - 1) * limit)
      .limit(limit)
      .orderBy('created_at', 'desc');

    return {
      charities,
      total: totalCount,
      page,
      limit,
      pages: limit > 0 ? Math.ceil(totalCount / limit) : 0,
    };
  }

  /**
   * Get charity by ID
   */
  static async getCharityById(charityId: string) {
    const db = requireDb();
    const charity = await db('charities')
      .where('charity_id', charityId)
      .first();

    if (!charity) {
      return null;
    }

    // Get active campaigns
    const campaigns = await db('campaigns')
      .where('charity_id', charityId)
      .where('status', 'active')
      .select('*');

    // Get total impact stats
    const stats = await db('donations')
      .where('campaign_id', 'in',
        db('campaigns').where('charity_id', charityId).select('campaign_id')
      )
      .where('status', 'success')
      .select(
        db.raw('COUNT(*) as total_donors'),
        db.raw('SUM(amount) as total_raised')
      )
      .first();

    return {
      ...charity,
      campaigns,
      impactStats: stats,
    };
  }

  /**
   * Register charity
   */
  static async registerCharity(userId: string, data: any) {
    const db = requireDb();

    const charity = await db('charities')
      .insert({
        charity_id: uuidv4(),
        user_id: userId,
        name: data.name,
        description: data.description,
        category: data.category,
        registration_number: data.registration_number,
        contact_info: data.contact_info,
        website_url: data.website_url,
        documents_url: data.documents_url || [],
        verification_status: 'pending',
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    return charity[0];
  }

  /**
   * Update charity profile
   */
  static async updateCharityProfile(charityId: string, data: any) {
    const db = requireDb();

    const charity = await db('charities')
      .where('charity_id', charityId)
      .update({
        ...data,
        updated_at: new Date(),
      })
      .returning('*');

    return charity[0];
  }

  /**
   * Verify charity (admin action)
   */
  static async verifyCharity(charityId: string, adminId: string, notes?: string) {
    const db = requireDb();

    const charity = await db('charities')
      .where('charity_id', charityId)
      .update({
        verification_status: 'verified',
        verification_date: new Date(),
        verified_by: adminId,
        updated_at: new Date(),
      })
      .returning('*');

    // TODO: Send notification to charity

    return charity[0];
  }

  /**
   * Reject charity (admin action)
   */
  static async rejectCharity(charityId: string, adminId: string, reason: string) {
    const db = requireDb();

    const charity = await db('charities')
      .where('charity_id', charityId)
      .update({
        verification_status: 'rejected',
        verification_date: new Date(),
        verified_by: adminId,
        updated_at: new Date(),
      })
      .returning('*');

    // TODO: Send rejection notification to charity

    return charity[0];
  }

  /**
   * Get charity statistics
   */
  static async getCharityStats(charityId: string) {
    const db = requireDb();

    const donationStats = await db('donations')
      .join('campaigns', 'donations.campaign_id', 'campaigns.campaign_id')
      .where('campaigns.charity_id', charityId)
      .where('donations.status', 'success')
      .select(
        db.raw('COUNT(*) as total_donations'),
        db.raw('SUM(donations.amount) as total_raised'),
        db.raw('COUNT(DISTINCT donors.donor_id) as unique_donors'),
        db.raw('AVG(donations.amount) as average_donation'),
        db.raw('MAX(donations.amount) as largest_donation')
      )
      .first();

    const campaignStats = await db('campaigns')
      .where('charity_id', charityId)
      .select(
        db.raw('COUNT(*) as total_campaigns'),
        db.raw('COUNT(CASE WHEN status = \'active\' THEN 1 END) as active_campaigns'),
        db.raw('COUNT(CASE WHEN status = \'completed\' THEN 1 END) as completed_campaigns')
      )
      .first();

    return {
      donations: donationStats,
      campaigns: campaignStats,
    };
  }

  /**
   * Get top charities by donations
   */
  static async getTopCharities(limit: number = 20) {
    const db = requireDb();

    return await db('charities')
      .where('verification_status', 'verified')
      .orderBy('total_raised', 'desc')
      .limit(limit)
      .select('*');
  }

  /**
   * Add impact story
   */
  static async addImpactStory(charityId: string, story: string, imageUrl?: string) {
    const db = requireDb();

    const charity = await db('charities')
      .where('charity_id', charityId)
      .first();

    const stories = charity?.impact_stories || [];
    stories.push({
      id: uuidv4(),
      story,
      image_url: imageUrl,
      created_at: new Date(),
    });

    return await db('charities')
      .where('charity_id', charityId)
      .update({
        impact_stories: stories,
        updated_at: new Date(),
      })
      .returning('*');
  }
}
