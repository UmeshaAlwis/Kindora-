import { getDatabase } from './database.service';
import { v4 as uuidv4 } from 'uuid';

export class MessageService {
  /**
   * Send message
   */
  static async sendMessage(senderId: string, data: any) {
    const db = getDatabase();

    const message = await db('messages')
      .insert({
        message_id: uuidv4(),
        sender_id: senderId,
        receiver_id: data.receiver_id,
        campaign_id: data.campaign_id,
        content: data.content,
        attachment_url: data.attachment_url,
        timestamp: new Date(),
        read_status: false,
      })
      .returning('*');

    return message[0];
  }

  /**
   * Get conversation with user
   */
  static async getConversation(userId1: string, userId2: string, limit: number = 50) {
    const db = getDatabase();

    const messages = await db('messages')
      .where((builder) => {
        builder
          .where({ sender_id: userId1, receiver_id: userId2 })
          .orWhere({ sender_id: userId2, receiver_id: userId1 });
      })
      .orderBy('timestamp', 'desc')
      .limit(limit)
      .select('*');

    // Mark as read
    await db('messages')
      .where({ receiver_id: userId1, sender_id: userId2 })
      .where('read_status', false)
      .update({ read_status: true, read_at: new Date() });

    return messages.reverse();
  }

  /**
   * Get user conversations list
   */
  static async getConversationsList(userId: string) {
    const db = getDatabase();

    return await db('messages')
      .where(function (this: any) {
        this.where('sender_id', userId).orWhere('receiver_id', userId);
      })
      .join('users', function (this: any) {
        this.on(function (this: any) {
          this.on('messages.sender_id', '=', 'users.user_id')
            .andOn('messages.receiver_id', '!=', userId)
            .orOn('messages.receiver_id', '=', 'users.user_id')
            .andOn('messages.sender_id', '!=', userId);
        });
      })
      .distinct('messages.sender_id', 'messages.receiver_id')
      .select(
        'users.*',
        db.raw('(SELECT COUNT(*) FROM messages WHERE read_status = false AND sender_id = users.user_id AND receiver_id = ?) as unread_count', [userId]),
        'messages.timestamp as last_message_time',
        'messages.content as last_message'
      )
      .orderBy('messages.timestamp', 'desc');
  }

  /**
   * Mark message as read
   */
  static async markAsRead(messageId: string) {
    const db = getDatabase();

    return await db('messages')
      .where('message_id', messageId)
      .update({
        read_status: true,
        read_at: new Date(),
      })
      .returning('*');
  }

  /**
   * Get unread message count
   */
  static async getUnreadCount(userId: string): Promise<number> {
    const db = getDatabase();

    const result = await db('messages')
      .where('receiver_id', userId)
      .where('read_status', false)
      .count('* as count')
      .first();

    return result?.count || 0;
  }

  /**
   * Get messages by campaign
   */
  static async getCampaignMessages(campaignId: string, limit: number = 50) {
    const db = getDatabase();

    return await db('messages')
      .where('campaign_id', campaignId)
      .join('users', 'messages.sender_id', 'users.user_id')
      .select(
        'messages.*',
        'users.full_name',
        'users.profile_image_url'
      )
      .orderBy('messages.timestamp', 'desc')
      .limit(limit);
  }

  /**
   * Delete message
   */
  static async deleteMessage(messageId: string, userId: string) {
    const db = getDatabase();

    // Only allow deletion by sender or within 1 hour of sending
    const message = await db('messages')
      .where('message_id', messageId)
      .first();

    if (!message || message.sender_id !== userId) {
      throw new Error('Unauthorized to delete this message');
    }

    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    if (new Date(message.timestamp) < oneHourAgo) {
      throw new Error('Message can only be deleted within 1 hour of sending');
    }

    await db('messages').where('message_id', messageId).delete();
  }

  /**
   * Edit message
   */
  static async editMessage(messageId: string, userId: string, newContent: string) {
    const db = getDatabase();

    const message = await db('messages')
      .where('message_id', messageId)
      .first();

    if (!message || message.sender_id !== userId) {
      throw new Error('Unauthorized to edit this message');
    }

    return await db('messages')
      .where('message_id', messageId)
      .update({
        content: newContent,
        edited_at: new Date(),
      })
      .returning('*');
  }
}
