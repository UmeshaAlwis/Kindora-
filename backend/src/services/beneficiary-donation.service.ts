import { WalletService } from './wallet.service';
import { supabase } from './supabase.service';
import { v4 as uuidv4 } from 'uuid';

export class BeneficiaryDonationService {
  /**
   * Create beneficiary donation record
   */
  static async createBeneficiaryDonation(donorId: string, data: any) {
    const donationId = uuidv4();
    const isWalletPayment = data.payment_method === 'wallet';
    const status = isWalletPayment ? 'completed' : 'pending';

    // If wallet payment, deduct from wallet first
    if (isWalletPayment) {
      await WalletService.deductFromWallet(donorId, data.amount, donationId);
    }

    // Create donation record in Supabase - specifically for beneficiary campaigns
    const donationData: any = {
      id: donationId,
      user_id: donorId,
      beneficiary_campaign_id: data.beneficiary_campaign_id,
      amount: data.amount,
      currency: 'LKR',
      payment_method: data.payment_method,
      status,
      donor_name: data.donor_name,
      donor_email: data.donor_email,
      donor_phone: data.donor_phone,
      is_anonymous: data.is_anonymous || false,
      message: data.message,
      transaction_id: null,
      created_at: new Date().toISOString(),
    };

    const donation = await supabase.insert('donations', donationData);

    // If wallet payment, immediately update beneficiary campaign and points
    if (isWalletPayment) {
      await this.updateBeneficiaryCampaignAmount(data.beneficiary_campaign_id, data.amount);
      await this.awardDonationPoints(donorId, data.amount);
    }

    return donation;
  }

  /**
   * Update beneficiary campaign amount after successful donation
   */
  private static async updateBeneficiaryCampaignAmount(beneficiaryCampaignId: string, amount: number) {
    try {
      // Get current beneficiary campaign
      const campaigns = await supabase.select<any>('beneficiary_campaigns', {
        select: 'raised_amount,id',
        filters: { id: beneficiaryCampaignId },
      });

      if (campaigns?.[0]) {
        const currentAmount = (campaigns[0].raised_amount as number) || 0;
        await supabase.update<any>(
          'beneficiary_campaigns',
          {
            raised_amount: currentAmount + amount,
            updated_at: new Date().toISOString(),
          },
          { id: beneficiaryCampaignId }
        );
      }
    } catch (error) {
      console.error('[BeneficiaryDonationService] Failed to update beneficiary campaign amount:', error);
    }
  }

  /**
   * Award points for beneficiary donation (gamification)
   */
  private static async awardDonationPoints(userId: string, amount: number) {
    // This can be implemented later for gamification
    console.log(
      `[BeneficiaryDonationService] Award points: ${Math.floor(amount)} points to user ${userId}`
    );
  }

  /**
   * Update beneficiary donation status
   */
  static async updateBeneficiaryDonationStatus(
    donationId: string,
    status: string,
    transactionId?: string
  ) {
    const donation = await supabase.update<any>(
      'donations',
      {
        status,
        transaction_id: transactionId,
        updated_at: new Date().toISOString(),
      },
      { id: donationId }
    );

    if (status === 'completed' && donation?.[0]) {
      // Update beneficiary campaign amount
      if (donation[0].beneficiary_campaign_id) {
        await this.updateBeneficiaryCampaignAmount(
          donation[0].beneficiary_campaign_id,
          donation[0].amount
        );
      }

      // Award points to donor (gamification)
      if (donation[0].user_id) {
        await this.awardDonationPoints(donation[0].user_id, donation[0].amount);
      }
    }

    return donation?.[0];
  }

  /**
   * Get user beneficiary donation history
   */
  static async getUserBeneficiaryDonationHistory(userId: string, page: number = 1, limit: number = 20) {
    try {
      // Get total count of donations to beneficiary campaigns
      const allDonations = await supabase.select<any>('donations', {
        select: 'id',
        filters: { user_id: userId },
      });

      // Filter for only beneficiary donations (where beneficiary_campaign_id is not null)
      const beneficiaryDonations = allDonations?.filter((d: any) => d.beneficiary_campaign_id !== null) || [];
      const total = beneficiaryDonations.length;

      // Get paginated donations
      const donations = await supabase.select<any>('donations', {
        filters: { user_id: userId },
        limit: limit * 2, // Fetch extra to account for filtering
        offset: 0,
        orderBy: { column: 'created_at', ascending: false },
      });

      // Filter for only beneficiary donations and apply pagination
      const beneficiaryDonationsFiltered = donations
        ?.filter((d: any) => d.beneficiary_campaign_id !== null)
        .slice((page - 1) * limit, page * limit) || [];

      return {
        donations: beneficiaryDonationsFiltered,
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      };
    } catch (error) {
      console.error('[BeneficiaryDonationService] Failed to get donation history:', error);
      throw error;
    }
  }

  /**
   * Get total donated by user to beneficiary campaigns
   */
  static async getTotalBeneficiaryDonatedByUser(userId: string): Promise<number> {
    try {
      const donations = await supabase.select<any>('donations', {
        select: 'amount',
        filters: {
          user_id: userId,
          status: 'completed',
        },
      });

      if (!donations || donations.length === 0) {
        return 0;
      }

      // Filter for only beneficiary donations
      const beneficiaryDonations = donations.filter((d: any) => d.beneficiary_campaign_id !== null);
      return beneficiaryDonations.reduce((sum: number, donation: any) => sum + (donation.amount || 0), 0);
    } catch (error) {
      console.error('[BeneficiaryDonationService] Failed to get total donated:', error);
      throw error;
    }
  }

  /**
   * Get total raised for a beneficiary campaign
   */
  static async getTotalRaisedForBeneficiaryCampaign(beneficiaryCampaignId: string): Promise<number> {
    try {
      const donations = await supabase.select<any>('donations', {
        select: 'amount',
        filters: {
          beneficiary_campaign_id: beneficiaryCampaignId,
          status: 'completed',
        },
      });

      if (!donations || donations.length === 0) {
        return 0;
      }

      return donations.reduce((sum: number, donation: any) => sum + (donation.amount || 0), 0);
    } catch (error) {
      console.error('[BeneficiaryDonationService] Failed to get total raised:', error);
      throw error;
    }
  }
}
