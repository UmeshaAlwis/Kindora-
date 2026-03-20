import { Router, Request, Response } from 'express';
import Joi from 'joi';
import jwt from 'jsonwebtoken';
import multer from 'multer';
import axios from 'axios';
import { v4 as uuidv4 } from 'uuid';
import { SupabaseClient } from '../services/supabase.service';
import { authenticateToken } from '../middleware/auth.middleware';
import { WalletService } from '../services/wallet.service';

const router = Router();
const supabase = new SupabaseClient();

const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'admin@gmail.com';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';
const ADMIN_NAME = process.env.ADMIN_NAME || 'Kindora Admin';
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

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

async function uploadImageToSupabaseStorage(file: Express.Multer.File) {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'Kindora';
  const folder = 'merchandise';

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error('Supabase configuration missing');
  }

  const timestamp = Date.now();
  const safeOriginalName = file.originalname.replace(/\s+/g, '_');
  const fileName = `${folder}/${folder}_${timestamp}_${safeOriginalName}`;
  const filePath = `${bucket}/${fileName}`;

  const uploadUrl = `${supabaseUrl}/storage/v1/object/${filePath}`;
  await axios.post(uploadUrl, file.buffer, {
    headers: {
      Authorization: `Bearer ${serviceRoleKey}`,
      apikey: serviceRoleKey,
      'Content-Type': file.mimetype,
    },
  });

  return `${supabaseUrl}/storage/v1/object/public/${filePath}`;
}

/**
 * POST /products/admin/login
 * Test admin login for react dashboard.
 */
router.post('/admin/login', async (req: Request, res: Response) => {
  const schema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required(),
  });

  const { error, value } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ success: false, error: error.message });
  }

  if (value.email !== ADMIN_EMAIL || value.password !== ADMIN_PASSWORD) {
    return res.status(401).json({ success: false, error: 'Invalid credentials' });
  }

  const token = jwt.sign(
    { email: ADMIN_EMAIL, role: 'admin' } as AdminTokenPayload,
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  return res.json({
    success: true,
    data: {
      token,
      user: {
        email: ADMIN_EMAIL,
        full_name: ADMIN_NAME,
        role: 'admin',
      },
    },
  });
});

/**
 * POST /products/admin/upload-image
 * Upload product image file to Supabase storage.
 */
router.post(
  '/admin/upload-image',
  upload.single('image'),
  async (req: Request, res: Response) => {
    const admin = requireAdmin(req, res);
    if (!admin) return;

    try {
      if (!req.file) {
        return res.status(400).json({ success: false, error: 'No file provided' });
      }
      const url = await uploadImageToSupabaseStorage(req.file);
      return res.json({ success: true, data: { url } });
    } catch (error: any) {
      return res.status(500).json({
        success: false,
        error: error.message || 'Failed to upload image',
      });
    }
  }
);

/**
 * GET /products
 * Public product listing for mobile Merch page.
 */
router.get('/', async (_req: Request, res: Response) => {
  try {
    const rows = await supabase.select<any>('merchandise', {
      select:
        'id,name,description,price,stock_quantity,category,image_url,is_active,created_at',
      filters: { is_active: true },
      orderBy: { column: 'created_at', ascending: false },
      limit: 200,
    });

    return res.json({ success: true, data: rows });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to fetch products',
    });
  }
});

/**
 * GET /products/admin
 * Admin product listing.
 */
router.get('/admin', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  try {
    const rows = await supabase.select<any>('merchandise', {
      select:
        'id,name,description,price,stock_quantity,category,image_url,is_active,created_at',
      orderBy: { column: 'created_at', ascending: false },
      limit: 500,
    });
    return res.json({ success: true, data: rows });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to fetch products',
    });
  }
});

/**
 * POST /products/admin
 * Admin create product.
 */
router.post('/admin', async (req: Request, res: Response) => {
  const admin = requireAdmin(req, res);
  if (!admin) return;

  const schema = Joi.object({
    name: Joi.string().min(2).max(255).required(),
    description: Joi.string().allow('').max(2000).optional(),
    price: Joi.number().positive().required(),
    stock_quantity: Joi.number().integer().min(0).required(),
    category: Joi.string().min(2).max(100).required(),
    image_url: Joi.string().uri().allow('', null).optional(),
    is_active: Joi.boolean().optional(),
  });
  const { error, value } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ success: false, error: error.message });
  }

  try {
    const inserted = await supabase.insert<any>('merchandise', {
      name: value.name,
      description: value.description || null,
      price: value.price,
      stock_quantity: value.stock_quantity,
      category: value.category,
      image_url: value.image_url || null,
      is_active: value.is_active ?? true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    return res.status(201).json({ success: true, data: inserted });
  } catch (err: any) {
    return res
      .status(500)
      .json({ success: false, error: err.message || 'Failed to create product' });
  }
});

/**
 * GET /products/:productId
 * Public single product details.
 */
router.get('/:productId', async (req: Request, res: Response) => {
  try {
    const { productId } = req.params;
    const rows = await supabase.select<any>('merchandise', {
      select:
        'id,name,description,price,stock_quantity,category,image_url,is_active,average_rating,review_count,created_at',
      filters: { id: productId, is_active: true },
      limit: 1,
    });
    const product = rows?.[0];
    if (!product) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    return res.json({ success: true, data: product });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to fetch product',
    });
  }
});

/**
 * POST /products/purchase
 * Donor purchases a merchandise item using wallet or card.
 */
router.post('/purchase', authenticateToken, async (req: Request, res: Response) => {
  const schema = Joi.object({
    product_id: Joi.string().uuid().required(),
    quantity: Joi.number().integer().min(1).max(50).required(),
    payment_method: Joi.string().valid('wallet', 'card').required(),
    card_last4: Joi.string().pattern(/^\d{4}$/).optional(),
    shipping_address: Joi.string().min(8).max(500).required(),
    receiver_phone: Joi.string().pattern(/^\+?[0-9]{9,15}$/).required(),
  });

  const { error, value } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ success: false, error: error.message });
  }

  const userId = req.userId;
  if (!userId) {
    return res.status(401).json({ success: false, error: 'Unauthorized' });
  }

  try {
    const users = await supabase.select<any>('users', {
      select: 'id,role',
      filters: { id: userId },
      limit: 1,
    });
    const role = users?.[0]?.role;
    if (role !== 'donor') {
      return res.status(403).json({
        success: false,
        error: 'Only donors can purchase merchandise',
      });
    }

    const products = await supabase.select<any>('merchandise', {
      select: 'id,name,price,stock_quantity,is_active',
      filters: { id: value.product_id },
      limit: 1,
    });
    const product = products?.[0];
    if (!product || !product.is_active) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }

    const stockQuantity = Number(product.stock_quantity) || 0;
    if (stockQuantity < value.quantity) {
      return res.status(400).json({
        success: false,
        error: `Insufficient stock. Available: ${stockQuantity}`,
      });
    }

    const unitPrice = Number(product.price) || 0;
    const totalAmount = unitPrice * value.quantity;
    const orderId = uuidv4();
    const transactionId =
      value.payment_method === 'card'
        ? `card_txn_${Date.now()}`
        : `wallet_txn_${Date.now()}`;

    if (value.payment_method === 'wallet') {
      const balance = await WalletService.getWalletBalance(userId);
      if (balance < totalAmount) {
        return res.status(400).json({
          success: false,
          error: `Insufficient wallet balance. Available: LKR ${balance.toFixed(2)}`,
        });
      }
      await WalletService.deductFromWallet(userId, totalAmount, orderId);
    }

    await supabase.insert('merchandise_orders', {
      id: orderId,
      user_id: userId,
      merchandise_id: product.id,
      quantity: value.quantity,
      unit_price: unitPrice,
      total_amount: totalAmount,
      payment_method: value.payment_method,
      shipping_address: value.shipping_address,
      receiver_phone: value.receiver_phone,
      status: 'success',
      transaction_id: transactionId,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });

    await supabase.update(
      'merchandise',
      {
        stock_quantity: stockQuantity - value.quantity,
        updated_at: new Date().toISOString(),
      },
      { id: product.id }
    );

    return res.status(201).json({
      success: true,
      message: 'Purchase successful',
      data: {
        order_id: orderId,
        product_id: product.id,
        quantity: value.quantity,
        total_amount: totalAmount,
        payment_method: value.payment_method,
        transaction_id: transactionId,
      },
    });
  } catch (err: any) {
    return res.status(500).json({
      success: false,
      error: err.message || 'Failed to complete purchase',
    });
  }
});

export default router;

