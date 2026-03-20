import { Router, Request, Response } from 'express';
import Joi from 'joi';
import jwt from 'jsonwebtoken';
import { SupabaseClient } from '../services/supabase.service';

const router = Router();
const supabase = new SupabaseClient();
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

type AdminTokenPayload = {
  email: string;
  role: 'admin';
};

function getBearerToken(req: Request): string | null {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) return null;
  return header.slice(7);
}

function requireAdmin(req: Request, res: Response): AdminTokenPayload | null {
  const token = getBearerToken(req);
  if (!token) {
    res.status(401).json({ success: false, error: 'Admin token required' });
    return null;
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as AdminTokenPayload;
    if (decoded.role !== 'admin') {
      res.status(403).json({ success: false, error: 'Admin access denied' });
      return null;
    }
    return decoded;
  } catch (_) {
    res.status(401).json({ success: false, error: 'Invalid admin token' });
    return null;
  }
}

router.get('/users', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    const rows = await supabase.select<any>('users', {
      select: 'id,email,full_name,role,is_active,created_at,last_login',
      orderBy: { column: 'created_at', ascending: false },
      limit: 1000,
    });
    return res.json({ success: true, data: rows });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

router.patch('/users/:userId/status', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  const schema = Joi.object({ is_active: Joi.boolean().required() });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ success: false, error: error.message });

  try {
    const updated = await supabase.update<any>(
      'users',
      { is_active: value.is_active, updated_at: new Date().toISOString() },
      { id: req.params.userId }
    );
    return res.json({ success: true, data: updated });
  } catch (err: any) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

router.get('/campaigns', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    const rows = await supabase.select<any>('campaigns', {
      select:
        'id,title,category,target_amount,raised_amount,status,user_id,created_at,end_date',
      orderBy: { column: 'created_at', ascending: false },
      limit: 1000,
    });
    return res.json({ success: true, data: rows });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

router.patch('/campaigns/:campaignId/status', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  const schema = Joi.object({
    status: Joi.string().valid('active', 'paused', 'completed', 'cancelled').required(),
  });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ success: false, error: error.message });

  try {
    const updated = await supabase.update<any>(
      'campaigns',
      { status: value.status, updated_at: new Date().toISOString() },
      { id: req.params.campaignId }
    );
    return res.json({ success: true, data: updated });
  } catch (err: any) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

router.get('/beneficiary-campaigns', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    const rows = await supabase.select<any>('beneficiary_campaigns', {
      select: 'id,title,target_amount,raised_amount,status,beneficiary_user_id,created_at',
      orderBy: { column: 'created_at', ascending: false },
      limit: 1000,
    });
    return res.json({ success: true, data: rows });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

router.patch(
  '/beneficiary-campaigns/:campaignId/status',
  async (req: Request, res: Response) => {
    const admin = requireAdmin(req, res);
    if (!admin) return;

    const schema = Joi.object({
      status: Joi.string().valid('active', 'paused', 'completed', 'cancelled').required(),
    });
    const { error, value } = schema.validate(req.body);
    if (error) return res.status(400).json({ success: false, error: error.message });

    try {
      const updated = await supabase.update<any>(
        'beneficiary_campaigns',
        { status: value.status, updated_at: new Date().toISOString() },
        { id: req.params.campaignId }
      );
      return res.json({ success: true, data: updated });
    } catch (err: any) {
      return res.status(500).json({ success: false, error: err.message });
    }
  }
);

router.get('/merchandise', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    const rows = await supabase.select<any>('merchandise', {
      select:
        'id,name,price,stock_quantity,category,is_active,average_rating,review_count,created_at',
      orderBy: { column: 'created_at', ascending: false },
      limit: 1000,
    });
    return res.json({ success: true, data: rows });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

router.patch('/merchandise/:id/status', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  const schema = Joi.object({ is_active: Joi.boolean().required() });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ success: false, error: error.message });

  try {
    const updated = await supabase.update<any>(
      'merchandise',
      { is_active: value.is_active, updated_at: new Date().toISOString() },
      { id: req.params.id }
    );
    return res.json({ success: true, data: updated });
  } catch (err: any) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

router.delete('/merchandise/:id', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    await supabase.update(
      'merchandise',
      {
        is_active: false,
        updated_at: new Date().toISOString(),
      },
      { id: req.params.id }
    );
    return res.json({ success: true, message: 'Merch item removed (soft delete)' });
  } catch (err: any) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

router.get('/feed-posts', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    const limit = Math.min(1000, Math.max(1, Number(req.query.limit) || 200));
    const rows = await supabase.select<any>('feed_posts', {
      select:
        'id,user_id,content,media_url,media_type,likes_count,comments_count,created_at',
      orderBy: { column: 'created_at', ascending: false },
      limit,
    });

    const userIds = Array.from(
      new Set((rows || []).map((r: any) => r.user_id).filter(Boolean))
    );
    const users =
      userIds.length > 0
        ? await Promise.all(
            userIds.map(async (id) => {
              const userRows = await supabase.select<any>('users', {
                select: 'id,full_name,email',
                filters: { id },
                limit: 1,
              });
              return userRows?.[0];
            })
          )
        : [];
    const userMap = new Map((users || []).filter(Boolean).map((u: any) => [u.id, u]));
    const enriched = (rows || []).map((post: any) => {
      const u = userMap.get(post.user_id);
      return {
        ...post,
        user_name: u?.full_name || u?.email || 'User',
        user_email: u?.email || null,
      };
    });

    return res.json({ success: true, data: enriched });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to fetch feed posts',
    });
  }
});

router.delete('/feed-posts/:postId', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    await supabase.delete('feed_posts', { id: req.params.postId });
    return res.json({ success: true, message: 'Feed post deleted' });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to delete feed post',
    });
  }
});

export default router;
