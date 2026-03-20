import { supabase } from './supabase.service';
import { v4 as uuidv4 } from 'uuid';

export class WalletService {
  /**
   * Get user wallet balance
   */
  static async getWalletBalance(userId: string): Promise<number> {
    try {
      const wallets = await supabase.select<any>('wallets', {
        select: 'balance',
        filters: { user_id: userId },
      });

      console.log('[WalletService] Raw Supabase response:', { wallets, firstWallet: wallets?.[0] });

      const balance = wallets?.[0]?.balance || 0;
      console.log('[WalletService] Extracted balance:', balance, 'Type:', typeof balance);

      // Handle balance as string (Supabase returns DECIMAL as string)
      return typeof balance === 'string' ? parseFloat(balance) : balance;
    } catch (error) {
      console.error('[WalletService] Error fetching wallet balance:', error);
      throw error;
    }
  }

  /**
   * Initialize wallet for new user
   */
  static async initializeWallet(userId: string, initialBalance: number = 0) {
    try {
      await supabase.insert('wallets', {
        wallet_id: uuidv4(),
        user_id: userId,
        balance: initialBalance,
        total_recharged: initialBalance,
        total_spent: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });
    } catch (error) {
      console.error('[WalletService] Error initializing wallet:', error);
      throw error;
    }
  }

  /**
   * Deduct from wallet (for donations)
   */
  static async deductFromWallet(userId: string, amount: number, reference_id: string) {
    try {
      // Get current balance and wallet_id
      const wallets = await supabase.select<any>('wallets', {
        select: 'balance,wallet_id',
        filters: { user_id: userId },
      });

      const wallet = wallets?.[0];
      if (!wallet) {
        throw new Error('Wallet not found');
      }

      if (wallet.balance < amount) {
        throw new Error('Insufficient wallet balance');
      }

      // Create transaction record
      await supabase.insert('wallet_transactions', {
        transaction_id: uuidv4(),
        wallet_id: wallet.wallet_id,
        type: 'debit',
        amount,
        reference_id,
        description: 'Donation from wallet',
        timestamp: new Date().toISOString(),
      });

      // Update wallet balance
      // IMPORTANT: DECIMAL columns must be sent as strings to Supabase REST API
      // Handle null values from database
      const currentTotalSpent = wallet.total_spent || 0;
      const newBalance = (wallet.balance - amount).toFixed(2);
      const newTotalSpent = (currentTotalSpent + amount).toFixed(2);
      
      console.log('[WalletService] UPDATE request - newBalance:', newBalance, 'newTotalSpent:', newTotalSpent, 'currentTotalSpent:', currentTotalSpent);
      
      const updated = await supabase.update<any>('wallets', 
        { 
          balance: parseFloat(newBalance),
          total_spent: parseFloat(newTotalSpent),
          updated_at: new Date().toISOString(),
        },
        { user_id: userId }
      );

      console.log('[WalletService] Wallet updated successfully:', updated);
      return updated;
    } catch (error) {
      console.error('[WalletService] Error deducting from wallet:', error);
      throw error;
    }
  }

  /**
   * Add to wallet (recharge)
   */
  static async addToWallet(userId: string, amount: number, reference_id?: string) {
    try {
      // Get wallet_id
      const wallets = await supabase.select<any>('wallets', {
        select: 'wallet_id,balance,total_recharged',
        filters: { user_id: userId },
      });

      const wallet = wallets?.[0];
      if (!wallet) {
        throw new Error('Wallet not found');
      }

      // Create transaction record
      await supabase.insert('wallet_transactions', {
        transaction_id: uuidv4(),
        wallet_id: wallet.wallet_id,
        type: 'credit',
        amount,
        reference_id,
        description: 'Wallet recharge',
        timestamp: new Date().toISOString(),
      });

      // Update wallet balance
      const updated = await supabase.update<any>('wallets',
        {
          balance: wallet.balance + amount,
          total_recharged: wallet.total_recharged + amount,
          updated_at: new Date().toISOString(),
        },
        { user_id: userId }
      );

      return updated;
    } catch (error) {
      console.error('[WalletService] Error adding to wallet:', error);
      throw error;
    }
  }

  /**
   * Get wallet transactions
   */
  static async getWalletTransactions(
    userId: string,
    page: number = 1,
    limit: number = 20
  ) {
    try {
      // Get wallet_id
      const wallets = await supabase.select<any>('wallets', {
        select: 'wallet_id',
        filters: { user_id: userId },
      });

      const wallet = wallets?.[0];
      if (!wallet) {
        return { transactions: [], total: 0, page, limit, pages: 0 };
      }

      // Get transactions with pagination
      const transactions = await supabase.select<any>('wallet_transactions', {
        filters: { wallet_id: wallet.wallet_id },
        orderBy: { column: 'timestamp', ascending: false },
        limit,
        offset: (page - 1) * limit,
      });

      // Get total count (approximate - Supabase returns count in headers)
      const allTransactions = await supabase.select<any>('wallet_transactions', {
        filters: { wallet_id: wallet.wallet_id },
      });

      const total = allTransactions.length;

      return {
        transactions,
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      };
    } catch (error) {
      console.error('[WalletService] Error fetching wallet transactions:', error);
      throw error;
    }
  }

  /**
   * Get wallet details
   */
  static async getWalletDetails(userId: string) {
    try {
      const wallets = await supabase.select<any>('wallets', {
        filters: { user_id: userId },
      });

      return wallets?.[0] || null;
    } catch (error) {
      console.error('[WalletService] Error fetching wallet details:', error);
      throw error;
    }
  }

  /**
   * Get beneficiary lifetime earnings from donations table.
   * Includes past completed beneficiary campaign donations even if
   * wallet-crediting logic was added later.
   */
  static async getBeneficiaryLifetimeEarnings(userId: string): Promise<number> {
    try {
      const campaigns = await supabase.select<any>('beneficiary_campaigns', {
        select: 'id',
        filters: { beneficiary_user_id: userId },
      });

      const campaignIds = (campaigns || []).map((c: any) => c.id).filter(Boolean);
      if (campaignIds.length == 0) return 0;

      // Supabase wrapper currently supports only eq filters; fetch completed
      // beneficiary donations and then filter campaign IDs in memory.
      const donations = await supabase.select<any>('donations', {
        select: 'beneficiary_campaign_id,amount,status',
        filters: { status: 'completed' },
      });

      const earned = (donations || [])
        .filter(
          (d: any) =>
            d.beneficiary_campaign_id &&
            campaignIds.includes(d.beneficiary_campaign_id)
        )
        .reduce((sum: number, d: any) => sum + (Number(d.amount) || 0), 0);

      return earned;
    } catch (error) {
      console.error('[WalletService] Error fetching beneficiary lifetime earnings:', error);
      throw error;
    }
  }
}
