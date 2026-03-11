import { supabase } from './supabase.service';
import { Campaign } from '../types';
import { v4 as uuidv4 } from 'uuid';

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
    try {
      const offset = (page - 1) * limit;
      const options: any = {
        select:
          'id,title,campaigner_name,category,campaign_category,target_amount,raised_amount,image_url,created_at',
        limit,
        offset,
        orderBy: { column: 'created_at', ascending: false },
      };

      // Add filters if provided
      if (filters.status || filters.category || filters.charityId) {
        options.filters = {};
        if (filters.status) options.filters.status = filters.status;
        if (filters.category) options.filters.category = filters.category;
        if (filters.charityId) options.filters.charity_id = filters.charityId;
      }

      const campaigns = await supabase.select<Campaign>('campaigns', options);

      return {
        campaigns,
        total: campaigns.length,
        page,
        limit,
        pages: Math.ceil(campaigns.length / limit),
      };
    } catch (error) {
      throw new Error(`Failed to fetch campaigns: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Get campaign by ID
   */
  static async getCampaignById(campaignId: string) {
    try {
      const campaigns = await supabase.select<Campaign>('campaigns', {
        filters: { id: campaignId },
      });
      return campaigns[0] || null;
    } catch (error) {
      throw new Error(`Failed to fetch campaign: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Get campaigns by category
   */
  static async getCampaignsByCategory(category: string) {
    try {
      const campaigns = await supabase.select<Campaign>('campaigns', {
        filters: { category },
        orderBy: { column: 'created_at', ascending: false },
      });
      return campaigns;
    } catch (error) {
      throw new Error(
        `Failed to fetch campaigns by category: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Create campaign
   */
  static async createCampaign(charityId: string, data: any) {
    try {
      const campaignData = {
        id: uuidv4(),
        title: data.title,
        campaigner_name: data.campaigner_name,
        category: data.category,
        campaign_category: data.campaign_category,
        target_amount: data.target_amount,
        image_url: data.image_url || null,
      };

      const campaign = await supabase.insert<Campaign>('campaigns', campaignData);

      return campaign;
    } catch (error) {
      throw new Error(`Failed to create campaign: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Update campaign
   */
  static async updateCampaign(campaignId: string, data: any) {
    try {
      const updateData = {
        ...data,
        updated_at: new Date().toISOString(),
      };

      const campaign = await supabase.update<Campaign>('campaigns', updateData, {
        id: campaignId,
      });

      return campaign;
    } catch (error) {
      throw new Error(`Failed to update campaign: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Get campaign progress
   */
  static async getCampaignProgress(campaignId: string) {
    try {
      const campaigns = await supabase.select<any>('campaigns', {
        filters: { id: campaignId },
        select: 'id,target_amount,raised_amount,end_date',
      });

      const campaign = campaigns[0];

      if (!campaign) {
        return null;
      }

      const progress = (campaign.raised_amount / campaign.target_amount) * 100;
      const daysLeft = this.calculateDaysLeft(campaign.end_date);

      return {
        target_amount: campaign.target_amount,
        raised_amount: campaign.raised_amount,
        progress: Math.min(progress, 100),
        daysLeft,
      };
    } catch (error) {
      throw new Error(
        `Failed to get campaign progress: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Calculate days left until campaign end date
   */
  private static calculateDaysLeft(endDate: string | Date): number {
    const end = new Date(endDate).getTime();
    const now = new Date().getTime();
    const daysLeft = Math.ceil((end - now) / (1000 * 60 * 60 * 24));
    return Math.max(daysLeft, 0);
  }

  /**
   * Update campaign raised amount (called after donation)
   */
  static async updateRaisedAmount(campaignId: string, amount: number) {
    try {
      const campaigns = await supabase.select<any>('campaigns', {
        filters: { id: campaignId },
        select: 'raised_amount',
      });

      const campaign = campaigns[0];
      const newRaisedAmount = (campaign?.raised_amount || 0) + amount;

      await supabase.update<Campaign>(
        'campaigns',
        { raised_amount: newRaisedAmount },
        { id: campaignId }
      );
    } catch (error) {
      throw new Error(`Failed to update raised amount: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Delete campaign
   */
  static async deleteCampaign(campaignId: string) {
    try {
      await supabase.delete('campaigns', { id: campaignId });
    } catch (error) {
      throw new Error(`Failed to delete campaign: ${error instanceof Error ? error.message : error}`);
    }
  }
}
