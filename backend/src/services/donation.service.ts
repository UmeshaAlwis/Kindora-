import { WalletService } from './wallet.service';
import { supabase } from './supabase.service';
import { Donation } from '../types';
import { v4 as uuidv4 } from 'uuid';

export class DonationService {
  /**
   * Create donation record
   */
  static async createDonation(donorId: string, data: any) {
    const donationId = uuidv4();
    const isWalletPayment = data.payment_method === 'wallet';
    const status = isWalletPayment ? 'success' : 'pending';

    // If wallet payment, deduct from wallet first
    if (isWalletPayment) {
      await WalletService.deductFromWallet(donorId, data.amount, donationId);
    }

    // Create donation record in Supabase
    const donation = await supabase.insert('donations', {
      id: donationId,
      user_id: donorId,
      campaign_id: data.campaign_id,
      amount: data.amount,
      currency: 'LKR',
      payment_method: data.payment_method,
      status,
      donor_name: data.donor_name,
      donor_email: data.donor_email,
      donor_phone: data.donor_phone,
      transaction_id: null,
      created_at: new Date().toISOString(),
    });

    // If wallet payment, immediately update campaign and points
    if (isWalletPayment) {
      await this.updateCampaignAmount(data.campaign_id, data.amount);
      await this.awardDonationPoints(donorId, data.amount);
    }

    return donation;
  }

  /**
   * Update donation status
   */
  static async updateDonationStatus(donationId: string, status: string, transactionId?: string) {
    const donation = await supabase.update<any>(
      'donations',
      {
        status,
        transaction_id: transactionId,
        updated_at: new Date().toISOString(),
      },
      { id: donationId }
    );

    if (status === 'success' && donation?.[0]) {
      // Update campaign current amount
      await this.updateCampaignAmount(donation[0].campaign_id, donation[0].amount);

      // Award points to donor (gamification)
      await this.awardDonationPoints(donation[0].user_id, donation[0].amount);
    }

    return donation?.[0];
  }

  /**
   * Update campaign amount after successful donation
   */
  private static async updateCampaignAmount(campaignId: string, amount: number) {
    try {
      // Get current campaign
      const campaigns = await supabase.select<any>('campaigns', {
        select: 'raised_amount,id',
        filters: { id: campaignId },
      });

      if (campaigns?.[0]) {
        const currentAmount = (campaigns[0].raised_amount as number) || 0;
        await supabase.update<any>(
          'campaigns',
          {
            raised_amount: currentAmount + amount,
            updated_at: new Date().toISOString(),
          },
          { id: campaignId }
        );
      }
    } catch (error) {
      console.error('[DonationService] Failed to update campaign amount:', error);
    }
  }

  /**
   * Award points for donation (gamification)
   */
  private static async awardDonationPoints(userId: string, amount: number) {
    // This can be implemented later for gamification
    // For now, just log it
    console.log(`[DonationService] Award points: ${Math.floor(amount)} points to user ${userId}`);
  }

  /**
   * Get user donation history
   */
  static async getUserDonationHistory(
    userId: string,
    page: number = 1,
    limit: number = 20
  ) {
    try {
      // Get total count
      const allDonations = await supabase.select<any>('donations', {
        select: 'id',
        filters: { user_id: userId },
      });

      const total = allDonations?.length || 0;

      // Get paginated donations
      const donations = await supabase.select<any>('donations', {
        filters: { user_id: userId },
        limit,
        offset: (page - 1) * limit,
        orderBy: { column: 'created_at', ascending: false },
      });

      return {
        donations: donations || [],
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      };
    } catch (error) {
      console.error('[DonationService] Failed to get donation history:', error);
      throw error;
    }
  }

  /**
   * Get donation analytics
   */
  static async getDonationAnalytics(startDate?: Date, endDate?: Date) {
    try {
      // Get successful donations
      const donations = await supabase.select<any>('donations', {
        filters: { status: 'success' },
      });

      // Basic analytics
      const stats = {
        total_donations: donations?.length || 0,
        total_amount: donations?.reduce((sum, d) => sum + (d.amount || 0), 0) || 0,
        average_amount: donations?.length ? donations.reduce((sum, d) => sum + (d.amount || 0), 0) / donations.length : 0,
        largest_donation: Math.max(...(donations?.map((d: any) => d.amount) || [0])) || 0,
        smallest_donation: Math.min(...(donations?.map((d: any) => d.amount) || [0])) || 0,
        unique_donors: new Set(donations?.map((d: any) => d.user_id)).size || 0,
      };

      // Group by payment method
      const byPaymentMethod: any = {};
      donations?.forEach((d: any) => {
        if (!byPaymentMethod[d.payment_method]) {
          byPaymentMethod[d.payment_method] = { count: 0, total: 0 };
        }
        byPaymentMethod[d.payment_method].count += 1;
        byPaymentMethod[d.payment_method].total += d.amount || 0;
      });

      return {
        stats,
        byPaymentMethod,
      };
    } catch (error) {
      console.error('[DonationService] Failed to get analytics:', error);
      throw error;
    }
  }

  /**
   * Set up recurring donation
   */
  static async setupRecurringDonation(userId: string, data: any) {
    try {
      const donation = await supabase.insert('donations', {
        id: uuidv4(),
        user_id: userId,
        campaign_id: data.campaign_id,
        amount: data.amount,
        currency: 'LKR',
        payment_method: data.payment_method || 'card',
        status: 'pending',
        created_at: new Date().toISOString(),
      });

      return donation;
    } catch (error) {
      console.error('[DonationService] Failed to setup recurring donation:', error);
      throw error;
    }
  }

  /**
   * Cancel recurring donation
   */
  static async cancelRecurringDonation(donationId: string) {
    try {
      await supabase.update(
        'donations',
        { status: 'cancelled' },
        { id: donationId }
      );
    } catch (error) {
      console.error('[DonationService] Failed to cancel donation:', error);
      throw error;
    }
  }

  /**
   * Get total donated by user
   */
  static async getTotalDonatedByUser(userId: string): Promise<number> {
    try {
      const donations = await supabase.select<any>('donations', {
        filters: { user_id: userId, status: 'success' },
      });

      return donations?.reduce((sum: number, d: any) => sum + (d.amount || 0), 0) || 0;
    } catch (error) {
      console.error('[DonationService] Failed to get total donations:', error);
      return 0;
    }
  }

  /**
   * Get campaign donation stats
   */
  static async getCampaignDonationStats(campaignId: string) {
    try {
      const campaigns = await supabase.select<any>('campaigns', {
        select: 'raised_amount,id',
        filters: { id: campaignId },
      });

      if (!campaigns?.[0]) {
        return null;
      }

      const campaign = campaigns[0];
      const donations = await supabase.select<any>('donations', {
        filters: { campaign_id: campaignId, status: 'success' },
      });

      return {
        campaign_id: campaignId,
        raised_amount: campaign.raised_amount,
        donation_count: donations?.length || 0,
        unique_donors: new Set(donations?.map((d: any) => d.user_id)).size || 0,
      };
    } catch (error) {
      console.error('[DonationService] Failed to get campaign stats:', error);
      return null;
    }
  }
}
