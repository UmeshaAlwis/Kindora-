import { Router, Request, Response, NextFunction } from 'express';
import MerchandiseController from '../controllers/merchandise.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

/**
 * GET /api/merchandise
 * Get all products (public, paginated)
 */
router.get('/', MerchandiseController.getAllProducts);

/**
 * GET /api/merchandise/search
 * Search products by name or category
 */
router.get('/search', MerchandiseController.searchProducts);

/**
 * GET /api/merchandise/category/:category
 * Get products by category
 */
router.get('/category/:category', MerchandiseController.getProductsByCategory);

/**
 * GET /api/merchandise/:productId
 * Get product by ID
 */
router.get('/:productId', MerchandiseController.getProductById);

/**
 * POST /api/merchandise
 * Create new product (protected - admin only)
 */
router.post(
  '/',
  authenticateToken,
  (req: Request, res: Response, next: NextFunction) => {
    MerchandiseController.createProduct(req, res, next);
  }
);

/**
 * PUT /api/merchandise/:productId
 * Update product (protected - admin only)
 */
router.put(
  '/:productId',
  authenticateToken,
  (req: Request, res: Response, next: NextFunction) => {
    MerchandiseController.updateProduct(req, res, next);
  }
);

/**
 * DELETE /api/merchandise/:productId
 * Delete product (protected - admin only)
 */
router.delete(
  '/:productId',
  authenticateToken,
  (req: Request, res: Response, next: NextFunction) => {
    MerchandiseController.deleteProduct(req, res, next);
  }
);

/**
 * POST /api/merchandise/stock/update
 * Bulk update stock (protected - admin only)
 */
router.post(
  '/stock/update',
  authenticateToken,
  (req: Request, res: Response, next: NextFunction) => {
    MerchandiseController.updateStock(req, res, next);
  }
);

export default router;
