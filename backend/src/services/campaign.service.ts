import { getDatabase } from './database.service';
import { Campaign } from '../types';
import { v4 as uuidv4 } from 'uuid';
import type { Knex } from 'knex';

export class CampaignService {
  /**
   * Get all campaigns with filters
   */
  static async getCampaigns(
    page: number = 1,
    limit: number = 20,
    filters: {
      status?: string;
      category?: string;
      charityId?: string;
      searchQuery?: string;
    } = {}
  ) {
    const db = getDatabase() as Knex;
    let query = db('campaigns')
      .join('charities', 'campaigns.charity_id', 'charities.charity_id')
      .select('campaigns.*', 'charities.name as charity_name', 'charities.logo_url');

    // Apply filters
    if (filters.status) {
      query = query.where('campaigns.status', filters.status);
    }
    if (filters.category) {
      query = query.where('campaigns.category', filters.category);
    }
    if (filters.charityId) {
      query = query.where('campaigns.charity_id', filters.charityId);
    }
    if (filters.searchQuery) {
      query = query.where('campaigns.title', 'ilike', `%${filters.searchQuery}%`);
    }

    const total = await query.clone().count('* as count').first();
    const campaigns = await query
      .offset((page - 1) * limit)
      .limit(limit)
      .orderBy('campaigns.created_at', 'desc');

    const totalCount = typeof total?.count === 'number' ? total.count : 0;
    return {
      campaigns: campaigns.map(this.formatCampaign),
      total: totalCount,
      page,
      limit,
      pages: Math.ceil(totalCount / limit),
    };
  }

  /**
   * Get campaign by ID
   */
  static async getCampaignById(campaignId: string) {
    const db = getDatabase() as Knex;
    const campaign = await db('campaigns')
      .join('charities', 'campaigns.charity_id', 'charities.charity_id')
      .where('campaigns.campaign_id', campaignId)
      .select('campaigns.*', 'charities.name as charity_name')
      .first();

    if (!campaign) {
      return null;
    }

    // Get beneficiaries
    const beneficiaries = await db('beneficiaries').where('campaign_id', campaignId);

    // Get recent donations
    const donations = await db('donations')
      .where('campaign_id', campaignId)
      .where('status', 'success')
      .orderBy('timestamp', 'desc')
      .limit(10)
      .select('donation_id', 'amount', 'timestamp');

    return {
      ...this.formatCampaign(campaign),
      beneficiaries,
      recentDonations: donations,
    };
  }

  /**
   * Create campaign
   */
  static async createCampaign(charityId: string, data: any) {
    const db = getDatabase() as Knex;

    const campaign = await db('campaigns')
      .insert({
        campaign_id: uuidv4(),
        charity_id: charityId,
        title: data.title,
        description: data.description,
        category: data.category,
        target_amount: data.target_amount,
        beneficiary_details: data.beneficiary_details,
        beneficiary_location: data.beneficiary_location,
        image_url: data.image_url,
        gallery_urls: data.gallery_urls || [],
        status: 'active',
        end_date: data.end_date,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    return campaign[0];
  }

  /**
   * Update campaign
   */
  static async updateCampaign(campaignId: string, data: any) {
    const db = getDatabase() as Knex;

    const campaign = await db('campaigns')
      .where('campaign_id', campaignId)
      .update({
        ...data,
        updated_at: new Date(),
      })
      .returning('*');

    return campaign[0];
  }

  /**
   * Get campaign progress
   */
  static async getCampaignProgress(campaignId: string) {
    const db = getDatabase() as Knex;

    const campaign = await db('campaigns')
      .where('campaign_id', campaignId)
      .select('target_amount', 'current_amount')
      .first();

    if (!campaign) {
      return null;
    }

    const progress = (campaign.current_amount / campaign.target_amount) * 100;
    const daysLeft = await this.getDaysLeft(campaignId);

    return {
      target_amount: campaign.target_amount,
      current_amount: campaign.current_amount,
      progress: Math.min(progress, 100),
      daysLeft,
    };
  }

  /**
   * Get days left for campaign
   */
  private static async getDaysLeft(campaignId: string): Promise<number> {
    const db = getDatabase() as Knex;

    const campaign = await db('campaigns')
      .where('campaign_id', campaignId)
      .select('end_date')
      .first();

    if (!campaign?.end_date) {
      return -1;
    }

    const today = new Date();
    const endDate = new Date(campaign.end_date);
    const daysLeft = Math.ceil((endDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

    return Math.max(daysLeft, 0);
  }

  /**
   * Get recommended campaigns for user
   */
  static async getRecommendedCampaigns(userId: string, limit: number = 10) {
    const db = getDatabase() as Knex;

    // Get user's donation history to understand preferences
    const userDonations = await db('donations')
      .join('campaigns', 'donations.campaign_id', 'campaigns.campaign_id')
      .where('donations.donor_id', userId)
      .select('campaigns.category')
      .groupBy('campaigns.category');

    const categories = userDonations.map((d: any) => d.category);

    // Get campaigns in similar categories that are active
    let query = db('campaigns')
      .where('campaigns.status', 'active')
      .join('charities', 'campaigns.charity_id', 'charities.charity_id')
      .select('campaigns.*', 'charities.name as charity_name');

    if (categories.length > 0) {
      query = query.whereIn('campaigns.category', categories);
    }

    const campaigns = await query
      .limit(limit)
      .orderBy('campaigns.current_amount', 'desc');

    return campaigns.map(this.formatCampaign);
  }

  /**
   * Format campaign response
   */
  private static formatCampaign(campaign: any): Campaign {
    const progress = (campaign.current_amount / campaign.target_amount) * 100;
    return {
      ...campaign,
      progress: Math.min(progress, 100),
    };
  }
}
