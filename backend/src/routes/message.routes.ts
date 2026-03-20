import { Router, Request, Response } from 'express';
import { authenticateToken } from '../middleware/auth.middleware';
import { SupabaseClient } from '../services/supabase.service';

const router = Router();

router.use(authenticateToken);

router.get('/me', async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const supabase = new SupabaseClient();
    const users = await supabase.select<any>('users', {
      select: 'id,role,full_name,email',
      filters: { id: userId },
      limit: 1,
    });

    const me = users[0];
    if (!me) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    return res.json({
      success: true,
      data: {
        userId: me.id,
        role: me.role || 'donor',
        displayName: me.full_name || me.email || 'User',
      },
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to load current user',
    });
  }
});

router.post('/', async (req: Request, res: Response) => {
  try {
    const senderId = req.userId;
    if (!senderId) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const recipientId = req.body.recipient_id || req.body.receiver_id || req.body.reciever_id;
    const content = (req.body.content || '').toString().trim();

    if (!recipientId || !content) {
      return res.status(400).json({
        success: false,
        error: 'recipient_id and content are required',
      });
    }

    const supabase = new SupabaseClient();
    const inserted = await supabase.insert<any>('messages', {
      sender_id: senderId,
      recipient_id: recipientId,
      content,
      created_at: new Date().toISOString(),
    });

    return res.status(201).json({
      success: true,
      data: inserted,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to send message',
    });
  }
});

router.get('/conversation/:partnerId', async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const partnerId = req.params.partnerId;
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const supabase = new SupabaseClient();
    const sent = await supabase.select<any>('messages', {
      select: 'id,sender_id,recipient_id,content,created_at,is_read',
      filters: { sender_id: userId, recipient_id: partnerId },
      orderBy: { column: 'created_at', ascending: true },
      limit: 200,
    });
    const received = await supabase.select<any>('messages', {
      select: 'id,sender_id,recipient_id,content,created_at,is_read',
      filters: { sender_id: partnerId, recipient_id: userId },
      orderBy: { column: 'created_at', ascending: true },
      limit: 200,
    });

    const combined = [...sent, ...received].sort(
      (a, b) =>
        new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
    );

    // Best-effort mark incoming messages as read.
    try {
      await supabase.update<any>(
        'messages',
        { is_read: true },
        { sender_id: partnerId, recipient_id: userId, is_read: false }
      );
    } catch (_) {
      // Ignore read-status failures.
    }

    const normalized = combined.map((m) => ({
      id: m.id,
      sender_id: m.sender_id,
      receiver_id: m.recipient_id,
      content: m.content,
      created_at: m.created_at,
    }));

    return res.json({ success: true, data: normalized });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to load conversation',
    });
  }
});

router.get('/conversations', async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const supabase = new SupabaseClient();
    const sent = await supabase.select<any>('messages', {
      select: 'id,sender_id,recipient_id,content,created_at',
      filters: { sender_id: userId },
      orderBy: { column: 'created_at', ascending: false },
      limit: 200,
    });
    const received = await supabase.select<any>('messages', {
      select: 'id,sender_id,recipient_id,content,created_at,is_read',
      filters: { recipient_id: userId },
      orderBy: { column: 'created_at', ascending: false },
      limit: 200,
    });

    const all = [...sent, ...received].sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    );

    const latestByPartner = new Map<string, any>();
    for (const msg of all) {
      const partnerId = msg.sender_id === userId ? msg.recipient_id : msg.sender_id;
      if (!latestByPartner.has(partnerId)) {
        latestByPartner.set(partnerId, msg);
      }
    }

    const previews: Array<{
      partnerId: string;
      partnerName: string;
      lastMessage: string;
      lastMessageAt: string;
      lastMessageSenderId: string;
      unreadCount: number;
    }> = [];

    for (const [partnerId, msg] of latestByPartner.entries()) {
      const users = await supabase.select<any>('users', {
        select: 'id,full_name,email',
        filters: { id: partnerId },
        limit: 1,
      });
      const partner = users[0];
      previews.push({
        partnerId,
        partnerName: partner?.full_name || partner?.email || 'User',
        lastMessage: msg.content || '',
        lastMessageAt: msg.created_at,
        lastMessageSenderId: msg.sender_id || '',
        unreadCount: received.filter(
          (r) => r.sender_id === partnerId && r.is_read === false
        ).length,
      });
    }

    previews.sort(
      (a, b) =>
        new Date(b.lastMessageAt).getTime() -
        new Date(a.lastMessageAt).getTime()
    );

    return res.json({ success: true, data: previews });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to load conversations',
    });
  }
});

export default router;
