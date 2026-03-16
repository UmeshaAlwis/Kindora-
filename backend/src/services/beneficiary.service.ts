import { supabase } from './supabase.service';
import { v4 as uuidv4 } from 'uuid';

export interface BeneficiaryDetails {
  id: string;
  user_id: string;
  full_name: string;
  nic: string;
  address: string;
  bank_account_holder_name: string;
  bank_account_number: string;
  bank_name: string;
  bank_code: string;
  profile_completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface BeneficiaryCampaign {
  id: string;
  beneficiary_user_id: string;
  full_name: string;
  title: string;
  description: string;
  target_amount: number;
  raised_amount: number;
  image_url: string | null;
  status: string;
  created_at: string;
  updated_at: string;
}

export class BeneficiaryService {
  /**
   * Get beneficiary details by user ID
   */
  static async getBeneficiaryDetails(userId: string): Promise<BeneficiaryDetails | null> {
    try {
      const details = await supabase.select<BeneficiaryDetails>('beneficiary_details', {
        filters: { user_id: userId },
      });
      return details[0] || null;
    } catch (error) {
      throw new Error(
        `Failed to fetch beneficiary details: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Create beneficiary details
   */
  static async createBeneficiaryDetails(userId: string, data: any): Promise<BeneficiaryDetails> {
    try {
      const beneficiaryData = {
        id: uuidv4(),
        user_id: userId,
        full_name: data.full_name,
        nic: data.nic,
        address: data.address,
        bank_account_holder_name: data.bank_account_holder_name,
        bank_account_number: data.bank_account_number,
        bank_name: data.bank_name,
        bank_code: data.bank_code,
        profile_completed: true,
      };

      console.log('[BeneficiaryService] Inserting beneficiary details:', beneficiaryData);
      const details = await supabase.insert<BeneficiaryDetails>('beneficiary_details', beneficiaryData);

      return details;
    } catch (error) {
      throw new Error(
        `Failed to create beneficiary details: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Update beneficiary details
   */
  static async updateBeneficiaryDetails(userId: string, data: any): Promise<BeneficiaryDetails> {
    try {
      const updateData = {
        ...data,
        updated_at: new Date().toISOString(),
      };

      // Remove user_id to prevent updates
      delete updateData.user_id;

      const details = await supabase.update<BeneficiaryDetails>('beneficiary_details', updateData, {
        user_id: userId,
      });

      return details;
    } catch (error) {
      throw new Error(
        `Failed to update beneficiary details: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Get all campaigns for a beneficiary
   */
  static async getBeneficiaryCampaigns(userId: string): Promise<BeneficiaryCampaign[]> {
    try {
      const campaigns = await supabase.select<BeneficiaryCampaign>('beneficiary_campaigns', {
        filters: { beneficiary_user_id: userId },
        orderBy: { column: 'created_at', ascending: false },
      });
      return campaigns;
    } catch (error) {
      throw new Error(
        `Failed to fetch beneficiary campaigns: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Get campaign by ID
   */
  static async getCampaignById(campaignId: string): Promise<BeneficiaryCampaign | null> {
    try {
      const campaigns = await supabase.select<BeneficiaryCampaign>('beneficiary_campaigns', {
        filters: { id: campaignId },
      });
      return campaigns[0] || null;
    } catch (error) {
      throw new Error(`Failed to fetch campaign: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Create beneficiary campaign
   */
  static async createCampaign(userId: string, data: any): Promise<BeneficiaryCampaign> {
    try {
      const campaignData = {
        id: uuidv4(),
        beneficiary_user_id: userId,
        full_name: data.full_name,
        title: data.title,
        description: data.description,
        target_amount: data.target_amount,
        raised_amount: 0,
        image_url: data.image_url || null,
        status: 'active',
      };

      console.log('[BeneficiaryService] Inserting beneficiary campaign:', campaignData);
      const campaign = await supabase.insert<BeneficiaryCampaign>('beneficiary_campaigns', campaignData);

      return campaign;
    } catch (error) {
      throw new Error(
        `Failed to create beneficiary campaign: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Update beneficiary campaign
   */
  static async updateCampaign(campaignId: string, data: any): Promise<BeneficiaryCampaign> {
    try {
      const updateData = {
        ...data,
        updated_at: new Date().toISOString(),
      };

      // Remove beneficiary_user_id to prevent updates
      delete updateData.beneficiary_user_id;

      const campaign = await supabase.update<BeneficiaryCampaign>('beneficiary_campaigns', updateData, {
        id: campaignId,
      });

      return campaign;
    } catch (error) {
      throw new Error(
        `Failed to update beneficiary campaign: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Delete beneficiary campaign
   */
  static async deleteCampaign(campaignId: string): Promise<void> {
    try {
      await supabase.delete('beneficiary_campaigns', { id: campaignId });
    } catch (error) {
      throw new Error(
        `Failed to delete beneficiary campaign: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Get campaign progress
   */
  static async getCampaignProgress(campaignId: string): Promise<any> {
    try {
      const campaigns = await supabase.select<any>('beneficiary_campaigns', {
        filters: { id: campaignId },
        select: 'id,target_amount,raised_amount',
      });

      const campaign = campaigns[0];

      if (!campaign) {
        return null;
      }

      const progress = (campaign.raised_amount / campaign.target_amount) * 100;

      return {
        target_amount: campaign.target_amount,
        raised_amount: campaign.raised_amount,
        progress: Math.min(progress, 100),
      };
    } catch (error) {
      throw new Error(
        `Failed to get campaign progress: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Update campaign raised amount (called after donation)
   */
  static async updateRaisedAmount(campaignId: string, amount: number): Promise<void> {
    try {
      const campaigns = await supabase.select<any>('beneficiary_campaigns', {
        filters: { id: campaignId },
        select: 'raised_amount',
      });

      const campaign = campaigns[0];
      const newRaisedAmount = (campaign?.raised_amount || 0) + amount;

      await supabase.update<BeneficiaryCampaign>(
        'beneficiary_campaigns',
        { raised_amount: newRaisedAmount },
        { id: campaignId }
      );
    } catch (error) {
      throw new Error(
        `Failed to update raised amount: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Get all beneficiary campaigns with filters
   */
  static async getAllCampaigns(
    page: number = 1,
    limit: number = 20,
    filters: {
      status?: string;
      searchQuery?: string;
    } = {}
  ): Promise<any> {
    try {
      const offset = (page - 1) * limit;
      const options: any = {
        select: 'id,beneficiary_user_id,full_name,title,target_amount,raised_amount,image_url,status,created_at',
        limit,
        offset,
        orderBy: { column: 'created_at', ascending: false },
      };

      // Add filters if provided
      if (filters.status) {
        options.filters = { status: filters.status };
      }

      const campaigns = await supabase.select<BeneficiaryCampaign>('beneficiary_campaigns', options);

      return {
        campaigns,
        total: campaigns.length,
        page,
        limit,
        pages: Math.ceil(campaigns.length / limit),
      };
    } catch (error) {
      throw new Error(
        `Failed to fetch beneficiary campaigns: ${error instanceof Error ? error.message : error}`
      );
    }
  }
}
