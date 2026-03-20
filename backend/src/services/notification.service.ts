import { supabase } from './supabase.service';
import { v4 as uuidv4 } from 'uuid';

export type NotificationType =
  | 'donation_success'
  | 'beneficiary_donation_success'
  | 'generic';

export class NotificationService {
  static async createNotification(params: {
    userId: string;
    type?: NotificationType;
    title: string;
    body?: string;
    metadata?: Record<string, any>;
  }) {
    const { userId, type = 'generic', title, body, metadata } = params;

    const notification = await supabase.insert('notifications', {
      id: uuidv4(),
      user_id: userId,
      type,
      title,
      body: body ?? null,
      metadata: metadata ?? {},
      is_read: false,
      created_at: new Date().toISOString(),
    });

    return notification;
  }

  static async getUserNotifications(params: {
    userId: string;
    limit?: number;
    offset?: number;
  }) {
    const { userId, limit = 20, offset = 0 } = params;

    const notifications = await supabase.select<any>('notifications', {
      select: 'id,type,title,body,metadata,is_read,created_at',
      filters: { user_id: userId },
      limit,
      offset,
      orderBy: { column: 'created_at', ascending: false },
    });

    return notifications ?? [];
  }

  static async getUnreadCount(userId: string) {
    const rows = await supabase.select<any>('notifications', {
      select: 'id',
      filters: { user_id: userId, is_read: false },
    });

    return rows?.length ?? 0;
  }

  static async markAllRead(userId: string) {
    const updated = await supabase.update<any>(
      'notifications',
      { is_read: true },
      { user_id: userId, is_read: false }
    );

    return updated;
  }

  static async markReadById(params: { userId: string; notificationId: string }) {
    const { userId, notificationId } = params;

    const updated = await supabase.update<any>(
      'notifications',
      { is_read: true },
      { id: notificationId, user_id: userId }
    );

    return updated;
  }
}

