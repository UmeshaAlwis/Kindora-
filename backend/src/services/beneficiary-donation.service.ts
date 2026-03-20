import { WalletService } from './wallet.service';
import { supabase } from './supabase.service';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError } from '../utils/errors';
import { NotificationService } from './notification.service';

export class BeneficiaryDonationService {
  /**
   * Create beneficiary donation record
   */
  static async createBeneficiaryDonation(donorId: string, data: any) {
    const donationType: string = data.donation_type ?? 'one-time';
    if (donationType === 'recurring') {
      return this.setupRecurringBeneficiaryDonation(donorId, data);
    }

    return this.createOneTimeBeneficiaryDonation(donorId, data);
  }

  private static async createOneTimeBeneficiaryDonation(donorId: string, data: any) {
    const donationId = uuidv4();
    const isWalletPayment = data.payment_method === 'wallet';
    const status = isWalletPayment ? 'completed' : 'pending';
    const amount =
      typeof data.amount === 'string' ? parseFloat(data.amount) : data.amount;

    // If wallet payment, deduct from wallet first
    if (isWalletPayment) {
      await WalletService.deductFromWallet(donorId, amount, donationId);
    }

    try {
      // Create donation record in Supabase - specifically for beneficiary campaigns
      const donationData: any = {
        id: donationId,
        user_id: donorId,
        beneficiary_campaign_id: data.beneficiary_campaign_id,
        amount: amount,
        currency: 'LKR',
        payment_method: data.payment_method,
        status,
        donor_name: data.donor_name,
        donor_email: data.donor_email,
        donor_phone: data.donor_phone,
        transaction_id: null,
        created_at: new Date().toISOString(),
      };

      const donation = await supabase.insert('donations', donationData);

      // If wallet payment, immediately update beneficiary campaign and points
      if (isWalletPayment) {
        await this.updateBeneficiaryCampaignAmount(
          data.beneficiary_campaign_id,
          amount
        );
        await this.awardDonationPoints(donorId, amount);

        // Create notifications (best-effort)
        try {
          // Notify donor
          await NotificationService.createNotification({
            userId: donorId,
            type: 'beneficiary_donation_success',
            title: 'Donation successful',
            body: `Thank you for supporting LKR ${amount}.`,
            metadata: {
              amount,
              beneficiary_campaign_id: data.beneficiary_campaign_id,
            },
          });

          // Notify beneficiary owner
          const campaigns = await supabase.select<any>('beneficiary_campaigns', {
            select: 'beneficiary_user_id',
            filters: { id: data.beneficiary_campaign_id },
          });
          const beneficiaryOwnerId = campaigns?.[0]?.beneficiary_user_id;
          if (beneficiaryOwnerId) {
            await NotificationService.createNotification({
              userId: beneficiaryOwnerId,
              type: 'beneficiary_donation_success',
              title: 'You received a new donation',
              body: `Someone donated LKR ${amount} to your beneficiary campaign.`,
              metadata: {
                amount,
                beneficiary_campaign_id: data.beneficiary_campaign_id,
                donor_id: donorId,
              },
            });
          }
        } catch (e) {
          console.error('[BeneficiaryDonationService] Failed to create wallet donation notifications:', e);
        }
      }

      return donation;
    } catch (error) {
      // If donation insert failed and wallet was debited, reverse the wallet deduction
      if (isWalletPayment) {
        console.error(
          '[BeneficiaryDonationService] Donation insert failed, reversing wallet deduction...',
          error
        );
        try {
          await WalletService.addToWallet(donorId, amount, `REVERSAL:${donationId}`);
          console.log(
            '[BeneficiaryDonationService] Wallet deduction reversed successfully'
          );
        } catch (reversalError) {
          console.error(
            '[BeneficiaryDonationService] CRITICAL: Failed to reverse wallet deduction!',
            reversalError
          );
          // Log this critical issue for manual intervention
        }
      }
      throw error;
    }
  }

  private static addFrequency(base: Date, frequency: string): Date {
    const d = new Date(base);
    switch (frequency) {
      case 'daily':
        d.setDate(d.getDate() + 1);
        return d;
      case 'weekly':
        d.setDate(d.getDate() + 7);
        return d;
      case 'monthly':
        d.setMonth(d.getMonth() + 1);
        return d;
      case 'yearly':
        d.setFullYear(d.getFullYear() + 1);
        return d;
      default:
        throw new ValidationError(`Unsupported recurring frequency: ${frequency}`);
    }
  }

  /**
   * Setup a recurring wallet-based beneficiary donation.
   * Card/bank transfer recurring is not supported (no stored payment method/subscription).
   */
  private static async setupRecurringBeneficiaryDonation(
    donorId: string,
    data: any
  ) {
    if (data.payment_method !== 'wallet') {
      throw new ValidationError(
        'Recurring beneficiary donations are only supported with wallet payments'
      );
    }

    const recurringFrequency: string | undefined = data.recurring_frequency;
    if (!recurringFrequency) {
      throw new ValidationError('recurring_frequency is required for recurring donations');
    }

    const endDateRaw = data.recurring_end_date;
    const endDate = endDateRaw ? new Date(endDateRaw) : null;
    const now = new Date();

    if (endDate && endDate.getTime() <= now.getTime()) {
      throw new ValidationError('recurring_end_date must be in the future');
    }

    // Process first installment immediately.
    const firstDonation = await this.createOneTimeBeneficiaryDonation(donorId, {
      ...data,
      donation_type: 'one-time',
    });

    const nextPaymentAt = this.addFrequency(now, recurringFrequency);

    // If next payment is beyond end date, we don't create a schedule.
    if (endDate && nextPaymentAt.getTime() > endDate.getTime()) {
      return firstDonation;
    }

    await supabase.insert('beneficiary_recurring_donations', {
      user_id: donorId,
      beneficiary_campaign_id: data.beneficiary_campaign_id,
      amount: typeof data.amount === 'string' ? parseFloat(data.amount) : data.amount,
      currency: 'LKR',
      recurring_frequency: recurringFrequency,
      recurring_end_date: endDate ? endDate.toISOString() : null,
      next_payment_at: nextPaymentAt.toISOString(),
      occurrences_done: 1,
      status: 'active',
      donor_name: data.donor_name,
      donor_email: data.donor_email,
      donor_phone: data.donor_phone ?? null,
    });

    return firstDonation;
  }

  /**
   * Scheduler entry-point for processing due recurring beneficiary donations.
   * Called periodically from `src/index.ts`.
   */
  static async processDueRecurringBeneficiaryDonations() {
    const now = new Date();

    // The current Supabase client wrapper only supports `eq` filters,
    // so we fetch active schedules and filter in JS.
    const schedules = await supabase.select<any>('beneficiary_recurring_donations', {
      select:
        'id,user_id,beneficiary_campaign_id,amount,recurring_frequency,recurring_end_date,next_payment_at,occurrences_done,donor_name,donor_email,donor_phone,status',
      filters: { status: 'active' },
      orderBy: { column: 'next_payment_at', ascending: true },
      limit: 200,
    });

    const due = (schedules || []).filter((s: any) => {
      const nextAt = new Date(s.next_payment_at);
      return nextAt.getTime() <= now.getTime();
    });

    for (const schedule of due) {
      try {
        // Reduce duplicate runs by marking as processing first.
        await supabase.update<any>(
          'beneficiary_recurring_donations',
          { status: 'processing' },
          { id: schedule.id }
        );

        const endDate = schedule.recurring_end_date
          ? new Date(schedule.recurring_end_date)
          : null;

        // Create one-time donation installment (wallet only)
        await this.createOneTimeBeneficiaryDonation(schedule.user_id, {
          beneficiary_campaign_id: schedule.beneficiary_campaign_id,
          amount: schedule.amount,
          payment_method: 'wallet',
          donor_name: schedule.donor_name,
          donor_email: schedule.donor_email,
          donor_phone: schedule.donor_phone ?? null,
          donation_type: 'one-time',
        });

        // Advance schedule
        const currentNextAt = new Date(schedule.next_payment_at);
        const nextPaymentAt = this.addFrequency(
          currentNextAt,
          schedule.recurring_frequency
        );

        const occurrencesDone =
          (typeof schedule.occurrences_done === 'string'
            ? parseInt(schedule.occurrences_done, 10)
            : schedule.occurrences_done) + 1;

        const shouldFinish = endDate && nextPaymentAt.getTime() > endDate.getTime();

        await supabase.update<any>(
          'beneficiary_recurring_donations',
          {
            next_payment_at: nextPaymentAt.toISOString(),
            occurrences_done: occurrencesDone,
            status: shouldFinish ? 'completed' : 'active',
          },
          { id: schedule.id }
        );
      } catch (error) {
        console.error(
          '[BeneficiaryDonationService] Failed processing recurring beneficiary donation:',
          {
            scheduleId: schedule.id,
            error,
          }
        );

        try {
          await supabase.update<any>(
            'beneficiary_recurring_donations',
            { status: 'failed' },
            { id: schedule.id }
          );
        } catch (updateError) {
          console.error(
            '[BeneficiaryDonationService] Failed updating schedule status after error:',
            updateError
          );
        }
      }
    }
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
      },
      { id: donationId }
    );

    const donationRow = Array.isArray(donation) ? donation?.[0] : donation;

    if (status === 'completed' && donationRow) {
      // Update beneficiary campaign amount
      if (donationRow.beneficiary_campaign_id) {
        await this.updateBeneficiaryCampaignAmount(
          donationRow.beneficiary_campaign_id,
          donationRow.amount
        );
      }

      // Award points to donor (gamification)
      if (donationRow.user_id) {
        await this.awardDonationPoints(donationRow.user_id, donationRow.amount);
      }

      // Create notifications (best-effort)
      try {
        if (donationRow.user_id) {
          await NotificationService.createNotification({
            userId: donationRow.user_id,
            type: 'beneficiary_donation_success',
            title: 'Donation successful',
            body: `Thank you for supporting LKR ${donationRow.amount}.`,
            metadata: {
              amount: donationRow.amount,
              beneficiary_campaign_id: donationRow.beneficiary_campaign_id ?? null,
            },
          });
        }

        if (donationRow.beneficiary_campaign_id) {
          const campaigns = await supabase.select<any>('beneficiary_campaigns', {
            select: 'beneficiary_user_id',
            filters: { id: donationRow.beneficiary_campaign_id },
          });
          const beneficiaryOwnerId = campaigns?.[0]?.beneficiary_user_id;
          if (beneficiaryOwnerId) {
            await NotificationService.createNotification({
              userId: beneficiaryOwnerId,
              type: 'beneficiary_donation_success',
              title: 'You received a new donation',
              body: `Someone donated LKR ${donationRow.amount} to your beneficiary campaign.`,
              metadata: {
                amount: donationRow.amount,
                beneficiary_campaign_id: donationRow.beneficiary_campaign_id,
                donor_id: donationRow.user_id,
              },
            });
          }
        }
      } catch (e) {
        console.error('[BeneficiaryDonationService] Failed to create card donation notifications:', e);
      }
    }

    return donationRow;
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
