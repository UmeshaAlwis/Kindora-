import { supabase } from './supabase.service';
import { Campaign } from '../types';
import { v4 as uuidv4 } from 'uuid';

const VOLUNTEER_BADGE_DEFINITIONS = [
  {
    id: 'vol_first_step',
    name: 'First Step',
    description: 'Joined your first volunteer campaign.',
    icon: 'volunteer_activism',
    evaluate: (ctx: { joinedCount: number }) => ctx.joinedCount >= 1,
  },
  {
    id: 'vol_team_player',
    name: 'Team Player',
    description: 'Joined 3 different campaigns as a volunteer.',
    icon: 'groups',
    evaluate: (ctx: { joinedCount: number }) => ctx.joinedCount >= 3,
  },
  {
    id: 'vol_impact_builder',
    name: 'Impact Builder',
    description: 'Joined 5 volunteer campaigns.',
    icon: 'emoji_events',
    evaluate: (ctx: { joinedCount: number }) => ctx.joinedCount >= 5,
  },
  {
    id: 'vol_super_volunteer',
    name: 'Super Volunteer',
    description: 'Joined 10 volunteer campaigns.',
    icon: 'military_tech',
    evaluate: (ctx: { joinedCount: number }) => ctx.joinedCount >= 10,
  },
  {
    id: 'vol_connector',
    name: 'Community Connector',
    description: 'Supported campaigns from 3 different organizers.',
    icon: 'handshake',
    evaluate: (ctx: { distinctOrganizers: number }) => ctx.distinctOrganizers >= 3,
  },
  {
    id: 'vol_quick_helper',
    name: 'Quick Helper',
    description: 'Joined a campaign within 24 hours of it going live.',
    icon: 'bolt',
    evaluate: (ctx: { hasQuickJoin: boolean }) => ctx.hasQuickJoin,
  },
  {
    id: 'vol_steady_heart',
    name: 'Steady Heart',
    description: 'Volunteered in two consecutive calendar months.',
    icon: 'event_repeat',
    evaluate: (ctx: { hasTwoMonthStreak: boolean }) => ctx.hasTwoMonthStreak,
  },
] as const;

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
      sortBy?: string;
    } = {}
  ) {
    try {
      const offset = (page - 1) * limit;
      const options: any = {
        select:
          'id,title,description,campaigner_name,category,campaign_category,target_amount,raised_amount,image_url,created_at,end_date',
        limit,
        offset,
        orderBy: { column: 'created_at', ascending: false },
      };

      if (filters.sortBy === 'ending_soon') {
        options.orderBy = { column: 'end_date', ascending: true };
      }

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
  static async createCampaign(userId: string, data: any) {
    try {
      const campaignData = {
        id: uuidv4(),
        user_id: userId,
        title: data.title,
        campaigner_name: data.campaigner_name,
        category: data.category,
        campaign_category: data.campaign_category,
        needs_volunteers: data.needs_volunteers ?? false,
        target_amount: data.target_amount,
        image_url: data.image_url || null,
        end_date: data.end_date || null,
      };

      console.log('[CampaignService] Inserting campaign:', campaignData);
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
   * Recommended campaigns (GET /campaigns/user/recommended):
   * active campaigns ordered by raised_amount (simple popularity heuristic).
   * When userId is set, excludes campaigns created by that user.
   */
  static async getRecommendedCampaigns(
    userId: string | undefined,
    limit: number = 10
  ) {
    try {
      const safeLimit = Math.min(100, Math.max(1, limit));
      const fetchLimit = Math.min(100, safeLimit * 4);

      const campaigns = await supabase.select<any>('campaigns', {
        select:
          'id,title,description,campaigner_name,category,campaign_category,target_amount,raised_amount,image_url,created_at,end_date,user_id,status',
        filters: { status: 'active' },
        limit: fetchLimit,
        orderBy: { column: 'raised_amount', ascending: false },
      });

      const list = campaigns || [];
      const filtered = userId
        ? list.filter((c: any) => c.user_id !== userId)
        : list;

      return filtered.slice(0, safeLimit);
    } catch (error) {
      throw new Error(
        `Failed to fetch recommended campaigns: ${error instanceof Error ? error.message : error}`
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
   * Volunteer endpoints
   * Volunteers can see/join campaigns that require volunteer support.
   */
  static async getVolunteerAvailableCampaigns(userId: string, limit: number = 20) {
    // Find which campaigns this volunteer already joined
    const joinedRows = await supabase.select<any>('campaign_volunteers', {
      select: 'campaign_id',
      filters: { user_id: userId },
    });
    const joinedSet = new Set((joinedRows || []).map((r: any) => r.campaign_id));

    const campaigns = await supabase.select<any>('campaigns', {
      select: 'id,title,description,image_url,end_date,needs_volunteers,user_id,status',
      filters: {
        needs_volunteers: true,
        status: 'active',
      },
      limit,
      orderBy: { column: 'end_date', ascending: true },
    });

    const enriched = [];
    for (const c of campaigns) {
      // Donor info (who created the campaign)
      const users = await supabase.select<any>('users', {
        select: 'id,full_name,email',
        filters: { id: c.user_id },
        limit: 1,
      });
      const donor = users?.[0];

      enriched.push({
        ...c,
        donor_full_name: donor?.full_name || donor?.email || 'User',
        donor_id: c.user_id,
        is_joined: joinedSet.has(c.id),
      });
    }

    return enriched;
  }

  static async getVolunteerJoinedCampaigns(userId: string) {
    const joinedRows = await supabase.select<any>('campaign_volunteers', {
      select: 'campaign_id',
      filters: { user_id: userId },
      limit: 100,
      orderBy: { column: 'created_at', ascending: false },
    });

    const campaignIds = (joinedRows || []).map((r: any) => r.campaign_id).filter(Boolean);
    if (campaignIds.length === 0) return [];

    const enriched = [];
    for (const campaignId of campaignIds) {
      const campaigns = await supabase.select<any>('campaigns', {
        select: 'id,title,description,image_url,end_date,needs_volunteers,user_id,status',
        filters: { id: campaignId },
        limit: 1,
      });

      const c = campaigns?.[0];
      if (!c) continue;

      const users = await supabase.select<any>('users', {
        select: 'id,full_name,email',
        filters: { id: c.user_id },
        limit: 1,
      });
      const donor = users?.[0];

      enriched.push({
        ...c,
        donor_full_name: donor?.full_name || donor?.email || 'User',
        donor_id: c.user_id,
        is_joined: true,
      });
    }

    return enriched;
  }

  static async joinVolunteerCampaign(userId: string, campaignId: string) {
    // Validate campaign eligibility
    const campaigns = await supabase.select<any>('campaigns', {
      select: 'id,needs_volunteers,status',
      filters: { id: campaignId },
      limit: 1,
    });

    const campaign = campaigns?.[0];
    if (!campaign) throw new Error('Campaign not found');
    if (campaign.status !== 'active' || campaign.needs_volunteers !== true) {
      throw new Error('Campaign is not available for volunteers');
    }

    // Avoid duplicates
    const existing = await supabase.select<any>('campaign_volunteers', {
      select: 'id',
      filters: { user_id: userId, campaign_id: campaignId },
      limit: 1,
    });
    if ((existing || []).length > 0) {
      return { joined: true };
    }

    await supabase.insert('campaign_volunteers', {
      campaign_id: campaignId,
      user_id: userId,
    });
    return { joined: true };
  }

  static async leaveVolunteerCampaign(userId: string, campaignId: string) {
    await supabase.delete('campaign_volunteers', {
      user_id: userId,
      campaign_id: campaignId,
    });
    return { left: true };
  }

  /**
   * Volunteer achievements (badges) from campaign_volunteers + campaigns.
   */
  static async getVolunteerBadgeSummary(userId: string) {
    const joinedRows = await supabase.select<any>('campaign_volunteers', {
      select: 'campaign_id,created_at',
      filters: { user_id: userId },
      limit: 500,
      orderBy: { column: 'created_at', ascending: true },
    });

    const joins = joinedRows || [];
    const uniqueCampaignIds = [
      ...new Set(
        joins.map((j: any) => j.campaign_id).filter((id: any) => typeof id === 'string' && id.length > 0)
      ),
    ] as string[];

    const campaignById = new Map<string, { id: string; created_at?: string; user_id?: string }>();
    for (const cid of uniqueCampaignIds) {
      const rows = await supabase.select<any>('campaigns', {
        select: 'id,created_at,user_id',
        filters: { id: cid },
        limit: 1,
      });
      const c = rows?.[0];
      if (c?.id) {
        campaignById.set(String(c.id), {
          id: String(c.id),
          created_at: c.created_at,
          user_id: c.user_id != null ? String(c.user_id) : undefined,
        });
      }
    }

    const distinctOrganizers = new Set<string>();
    campaignById.forEach((c) => {
      if (c.user_id && c.user_id.trim().length > 0) {
        distinctOrganizers.add(c.user_id);
      }
    });

    let hasQuickJoin = false;
    for (const j of joins) {
      const cid = String(j.campaign_id || '');
      const campaign = campaignById.get(cid);
      if (!campaign?.created_at || !j.created_at) continue;
      const campaignCreated = new Date(campaign.created_at);
      const joinedAt = new Date(j.created_at);
      if (Number.isNaN(campaignCreated.getTime()) || Number.isNaN(joinedAt.getTime())) continue;
      const diffMs = joinedAt.getTime() - campaignCreated.getTime();
      if (diffMs >= 0 && diffMs <= 24 * 60 * 60 * 1000) {
        hasQuickJoin = true;
        break;
      }
    }

    const joinMonths = new Set<string>();
    joins.forEach((j: any) => {
      if (!j.created_at) return;
      const dt = new Date(j.created_at);
      if (Number.isNaN(dt.getTime())) return;
      joinMonths.add(
        `${dt.getUTCFullYear()}-${String(dt.getUTCMonth() + 1).padStart(2, '0')}`
      );
    });
    const sortedMonths = Array.from(joinMonths).sort();
    let hasTwoMonthStreak = false;
    for (let i = 0; i < sortedMonths.length - 1; i++) {
      const [y1, m1] = sortedMonths[i].split('-').map(Number);
      const [y2, m2] = sortedMonths[i + 1].split('-').map(Number);
      const d1 = y1 * 12 + m1;
      const d2 = y2 * 12 + m2;
      if (d2 === d1 + 1) {
        hasTwoMonthStreak = true;
        break;
      }
    }

    const joinedCount = uniqueCampaignIds.length;
    const context = {
      joinedCount,
      distinctOrganizers: distinctOrganizers.size,
      hasQuickJoin,
      hasTwoMonthStreak,
    };

    const badges = VOLUNTEER_BADGE_DEFINITIONS.map((badge) => ({
      id: badge.id,
      name: badge.name,
      description: badge.description,
      icon: badge.icon,
      unlocked: badge.evaluate(context as any),
    }));

    return {
      stats: {
        campaigns_joined: joinedCount,
        distinct_organizers: distinctOrganizers.size,
      },
      badges,
    };
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
