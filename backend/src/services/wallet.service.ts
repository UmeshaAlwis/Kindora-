import { getDatabase } from './database.service';
import { v4 as uuidv4 } from 'uuid';

export class WalletService {
  /**
   * Get user wallet balance
   */
  static async getWalletBalance(userId: string): Promise<number> {
    const db = getDatabase();
    if (!db) throw new Error('Database not available');

    const wallet = await db('wallets')
      .where('user_id', userId)
      .select('balance')
      .first();

    return wallet?.balance || 0;
  }

  /**
   * Initialize wallet for new user
   */
  static async initializeWallet(userId: string, initialBalance: number = 0) {
    const db = getDatabase();
    if (!db) throw new Error('Database not available');

    await db('wallets').insert({
      wallet_id: uuidv4(),
      user_id: userId,
      balance: initialBalance,
      total_recharged: initialBalance,
      total_spent: 0,
      created_at: new Date(),
      updated_at: new Date(),
    });
  }

  /**
   * Deduct from wallet (for donations)
   */
  static async deductFromWallet(userId: string, amount: number, reference_id: string) {
    const db = getDatabase();
    if (!db) throw new Error('Database not available');

    // Get current balance
    const wallet = await db('wallets')
      .where('user_id', userId)
      .select('balance', 'wallet_id')
      .first();

    if (!wallet) {
      throw new Error('Wallet not found');
    }

    if (wallet.balance < amount) {
      throw new Error('Insufficient wallet balance');
    }

    // Create transaction record
    await db('wallet_transactions').insert({
      transaction_id: uuidv4(),
      wallet_id: wallet.wallet_id,
      type: 'debit',
      amount,
      reference_id,
      description: 'Donation from wallet',
      timestamp: new Date(),
    });

    // Update wallet balance
    const updatedWallet = await db('wallets')
      .where('user_id', userId)
      .decrement('balance', amount)
      .increment('total_spent', amount)
      .update({ updated_at: new Date() })
      .returning('*');

    return updatedWallet[0];
  }

  /**
   * Add to wallet (recharge)
   */
  static async addToWallet(userId: string, amount: number, reference_id?: string) {
    const db = getDatabase();
    if (!db) throw new Error('Database not available');

    const wallet = await db('wallets')
      .where('user_id', userId)
      .select('wallet_id')
      .first();

    if (!wallet) {
      throw new Error('Wallet not found');
    }

    // Create transaction record
    await db('wallet_transactions').insert({
      transaction_id: uuidv4(),
      wallet_id: wallet.wallet_id,
      type: 'credit',
      amount,
      reference_id,
      description: 'Wallet recharge',
      timestamp: new Date(),
    });

    // Update wallet balance
    const updatedWallet = await db('wallets')
      .where('user_id', userId)
      .increment('balance', amount)
      .increment('total_recharged', amount)
      .update({ updated_at: new Date() })
      .returning('*');

    return updatedWallet[0];
  }

  /**
   * Get wallet transactions
   */
  static async getWalletTransactions(
    userId: string,
    page: number = 1,
    limit: number = 20
  ) {
    const db = getDatabase();
    if (!db) throw new Error('Database not available');

    const wallet = await db('wallets')
      .where('user_id', userId)
      .select('wallet_id')
      .first();

    if (!wallet) {
      return { transactions: [], total: 0, page, limit, pages: 0 };
    }

    const total = await db('wallet_transactions')
      .where('wallet_id', wallet.wallet_id)
      .count('* as count')
      .first();

    const transactions = await db('wallet_transactions')
      .where('wallet_id', wallet.wallet_id)
      .offset((page - 1) * limit)
      .limit(limit)
      .orderBy('timestamp', 'desc');

    return {
      transactions,
      total: (total as any)?.count || 0,
      page,
      limit,
      pages: Math.ceil(((total as any)?.count || 0) / limit),
    };
  }

  /**
   * Get wallet details
   */
  static async getWalletDetails(userId: string) {
    const db = getDatabase();
    if (!db) throw new Error('Database not available');

    const wallet = await db('wallets')
      .where('user_id', userId)
      .first();

    return wallet || null;
  }
}
