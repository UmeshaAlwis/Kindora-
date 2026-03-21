import { Router, Request, Response } from 'express';
import Joi from 'joi';
import { authenticateToken } from '../middleware/auth.middleware';
import { SupabaseClient } from '../services/supabase.service';

const router = Router();

const updateNameSchema = Joi.object({
  full_name: Joi.string().trim().min(2).max(100).required(),
});

router.get('/me', authenticateToken, async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const supabase = new SupabaseClient();
    const rows = await supabase.select<any>('users', {
      select: 'id,email,role,full_name',
      filters: { id: userId },
      limit: 1,
    });

    const me = rows[0];
    if (!me) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    return res.json({ success: true, data: me });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to load user profile',
    });
  }
});

router.patch('/me/name', authenticateToken, async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const { error, value } = updateNameSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ success: false, error: error.message });
    }

    const supabase = new SupabaseClient();
    await supabase.update<any>(
      'users',
      {
        full_name: value.full_name,
        updated_at: new Date().toISOString(),
      },
      { id: userId }
    );

    const rows = await supabase.select<any>('users', {
      select: 'id,email,role,full_name',
      filters: { id: userId },
      limit: 1,
    });

    return res.json({
      success: true,
      data: rows[0] ?? null,
      message: 'Name updated successfully',
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to update name',
    });
  }
});

export default router;
