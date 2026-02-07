import { getDatabase } from './database.service';
import { Donation } from '../types';
import { v4 as uuidv4 } from 'uuid';

export class DonationService {
  /**
   * Create donation record
   */
  static async createDonation(donorId: string, data: any) {
    const db = getDatabase();

    const donation = await db('donations')
      .insert({
        donation_id: uuidv4(),
        donor_id: donorId,
        campaign_id: data.campaign_id,
        amount: data.amount,
        payment_method: data.payment_method,
        donation_type: data.donation_type || 'one-time',
        recurring_frequency: data.recurring_frequency,
        message: data.message,
        is_anonymous: data.is_anonymous || false,
        status: 'pending',
        timestamp: new Date(),
      })
      .returning('*');

    return donation[0];
  }

  /**
   * Update donation status
   */
  static async updateDonationStatus(donationId: string, status: string, transactionId?: string) {
    const db = getDatabase();

    const donation = await db('donations')
      .where('donation_id', donationId)
      .update({
        status,
        transaction_id: transactionId,
        updated_at: new Date(),
      })
      .returning('*');

    if (status === 'success') {
      // Update campaign current amount
      await this.updateCampaignAmount(donation[0].campaign_id, donation[0].amount);

      // Award points to donor (gamification)
      await this.awardDonationPoints(donation[0].donor_id, donation[0].amount);
    }

    return donation[0];
  }

  /**
   * Update campaign amount after successful donation
   */
  private static async updateCampaignAmount(campaignId: string, amount: number) {
    const db = getDatabase();

    await db('campaigns')
      .where('campaign_id', campaignId)
      .increment('current_amount', amount)
      .increment('donor_count', 1);
  }

  /**
   * Award points for donation (gamification)
   */
  private static async awardDonationPoints(userId: string, amount: number) {
    const db = getDatabase();

    // Calculate points: 1 LKR = 1 point
    const points = Math.floor(amount);

    await db('gamification')
      .where('user_id', userId)
      .increment('total_points', points)
      .increment('total_donations', 1);
  }

  /**
   * Get user donation history
   */
  static async getUserDonationHistory(
    userId: string,
    page: number = 1,
    limit: number = 20
  ) {
    const db = getDatabase();

    const total = await db('donations')
      .where('donor_id', userId)
      .count('* as count')
      .first();

    const donations = await db('donations')
      .where('donor_id', userId)
      .join('campaigns', 'donations.campaign_id', 'campaigns.campaign_id')
      .select(
        'donations.*',
        'campaigns.title as campaign_title',
        'campaigns.image_url'
      )
      .offset((page - 1) * limit)
      .limit(limit)
      .orderBy('donations.timestamp', 'desc');

    return {
      donations,
      total: total?.count || 0,
      page,
      limit,
      pages: Math.ceil((total?.count || 0) / limit),
    };
  }

  /**
   * Get donation analytics
   */
  static async getDonationAnalytics(startDate?: Date, endDate?: Date) {
    const db = getDatabase();

    let query = db('donations').where('status', 'success');

    if (startDate) {
      query = query.where('timestamp', '>=', startDate);
    }
    if (endDate) {
      query = query.where('timestamp', '<=', endDate);
    }

    const stats = await query.first().select(
      db.raw('COUNT(*) as total_donations'),
      db.raw('SUM(amount) as total_amount'),
      db.raw('AVG(amount) as average_amount'),
      db.raw('MAX(amount) as largest_donation'),
      db.raw('MIN(amount) as smallest_donation'),
      db.raw('COUNT(DISTINCT donor_id) as unique_donors')
    );

    // Get donations by payment method
    const byPaymentMethod = await query.groupBy('payment_method').select(
      'payment_method',
      db.raw('COUNT(*) as count'),
      db.raw('SUM(amount) as total')
    );

    // Get donations by day
    const byDay = await query.groupBy(db.raw('DATE(timestamp)')).select(
      db.raw('DATE(timestamp) as date'),
      db.raw('COUNT(*) as count'),
      db.raw('SUM(amount) as total')
    );

    return {
      stats: stats[0],
      byPaymentMethod,
      byDay,
    };
  }

  /**
   * Set up recurring donation
   */
  static async setupRecurringDonation(userId: string, data: any) {
    const db = getDatabase();

    const donation = await db('donations')
      .insert({
        donation_id: uuidv4(),
        donor_id: userId,
        campaign_id: data.campaign_id,
        amount: data.amount,
        payment_method: data.payment_method || 'card',
        donation_type: 'recurring',
        recurring_frequency: data.frequency,
        next_donation_date: data.start_date,
        status: 'pending',
        timestamp: new Date(),
      })
      .returning('*');

    return donation[0];
  }

  /**
   * Cancel recurring donation
   */
  static async cancelRecurringDonation(donationId: string) {
    const db = getDatabase();

    await db('donations')
      .where('donation_id', donationId)
      .where('donation_type', 'recurring')
      .update({
        status: 'cancelled',
      });
  }

  /**
   * Get total donated by user
   */
  static async getTotalDonatedByUser(userId: string): Promise<number> {
    const db = getDatabase();

    const result = await db('donations')
      .where('donor_id', userId)
      .where('status', 'success')
      .sum('amount as total')
      .first();

    return result?.total || 0;
  }

  /**
   * Get campaign donation stats
   */
  static async getCampaignDonationStats(campaignId: string) {
    const db = getDatabase();

    const campaign = await db('campaigns')
      .where('campaign_id', campaignId)
      .select('target_amount', 'current_amount', 'donor_count')
      .first();

    if (!campaign) {
      return null;
    }

    const topDonors = await db('donations')
      .where('campaign_id', campaignId)
      .where('status', 'success')
      .where('is_anonymous', false)
      .join('users', 'donations.donor_id', 'users.user_id')
      .select('users.full_name', 'donations.amount', 'donations.timestamp')
      .orderBy('donations.amount', 'desc')
      .limit(10);

    return {
      ...campaign,
      topDonors,
    };
  }
}
