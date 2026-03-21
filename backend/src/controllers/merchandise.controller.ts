import { Request, Response, NextFunction } from 'express';
import { MerchandiseService } from '../services/merchandise.service';
import { NotFoundError, ValidationError } from '../utils/errors';
import Joi from 'joi';
import Logger from '../utils/logger';

const logger = new Logger('MERCHANDISE_CONTROLLER');

const createProductSchema = Joi.object({
  name: Joi.string().required().min(3).max(255),
  description: Joi.string().optional(),
  price: Joi.number().required().positive(),
  stock_quantity: Joi.number().required().min(0),
  category: Joi.string().optional(),
  image_url: Joi.string().uri().optional().allow(null, ''),
  is_active: Joi.boolean().default(true),
});

const updateProductSchema = Joi.object({
  name: Joi.string().optional().min(3).max(255),
  description: Joi.string().optional(),
  price: Joi.number().optional().positive(),
  stock_quantity: Joi.number().optional().min(0),
  category: Joi.string().optional(),
  image_url: Joi.string().uri().optional().allow(null, ''),
  is_active: Joi.boolean().optional(),
});

export class MerchandiseController {
  /**
   * Get all products
   */
  static async getAllProducts(req: Request, res: Response, next: NextFunction) {
    try {
      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const result = await MerchandiseService.getAllProducts(page, limit);

      res.json({
        success: true,
        data: result.products,
        total: result.total,
        page: result.page,
        limit: result.limit,
        pages: result.pages,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get product by ID
   */
  static async getProductById(req: Request, res: Response, next: NextFunction) {
    try {
      const { productId } = req.params;

      const product = await MerchandiseService.getProductById(productId);

      if (!product) {
        throw new NotFoundError('Product');
      }

      res.json({
        success: true,
        data: product,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Create product
   */
  static async createProduct(req: Request, res: Response, next: NextFunction) {
    try {
      const { error: validationError, value } = createProductSchema.validate(req.body);
      if (validationError) {
        throw new ValidationError(validationError.message);
      }

      const product = await MerchandiseService.createProduct(value);

      logger.info(`Product created: ${product.id}`);

      res.status(201).json({
        success: true,
        data: product,
        message: 'Product created successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update product
   */
  static async updateProduct(req: Request, res: Response, next: NextFunction) {
    try {
      const { productId } = req.params;
      const { error: validationError, value } = updateProductSchema.validate(req.body);

      if (validationError) {
        throw new ValidationError(validationError.message);
      }

      const product = await MerchandiseService.updateProduct(productId, value);

      if (!product) {
        throw new NotFoundError('Product');
      }

      logger.info(`Product updated: ${productId}`);

      res.json({
        success: true,
        data: product,
        message: 'Product updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete product (soft delete - mark as inactive)
   */
  static async deleteProduct(req: Request, res: Response, next: NextFunction) {
    try {
      const { productId } = req.params;

      // Verify product exists
      const product = await MerchandiseService.getProductById(productId);
      if (!product) {
        throw new NotFoundError('Product');
      }

      await MerchandiseService.deleteProduct(productId);

      logger.info(`Product deleted: ${productId}`);

      res.json({
        success: true,
        message: 'Product deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Search products by name or category
   */
  static async searchProducts(req: Request, res: Response, next: NextFunction) {
    try {
      const query = req.query.query as string;
      const category = req.query.category as string;
      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const result = await MerchandiseService.searchProducts(query, category, page, limit);

      res.json({
        success: true,
        data: result.products,
        total: result.total,
        page: result.page,
        limit: result.limit,
        pages: result.pages,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get products by category
   */
  static async getProductsByCategory(req: Request, res: Response, next: NextFunction) {
    try {
      const { category } = req.params;
      const page = Math.max(1, parseInt(req.query.page as string) || 1);
      const limit = Math.min(100, parseInt(req.query.limit as string) || 20);

      const result = await MerchandiseService.getProductsByCategory(category, page, limit);

      res.json({
        success: true,
        data: result.products,
        total: result.total,
        page: result.page,
        limit: result.limit,
        pages: result.pages,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Bulk update product stock
   */
  static async updateStock(req: Request, res: Response, next: NextFunction) {
    try {
      const { updates } = req.body; // Array of { id, quantity }

      if (!Array.isArray(updates) || updates.length === 0) {
        throw new ValidationError('Updates array is required and must not be empty');
      }

      const result = await MerchandiseService.updateStock(updates);

      logger.info(`Stock updated for ${result.length} products`);

      res.json({
        success: true,
        data: result,
        message: `Updated stock for ${result.length} products`,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default MerchandiseController;
