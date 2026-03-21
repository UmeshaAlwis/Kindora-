import { getDatabase } from './database.service';
import { v4 as uuidv4 } from 'uuid';

export interface Product {
  id: string;
  name: string;
  description?: string;
  price: number;
  stock_quantity: number;
  category?: string;
  image_url?: string;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
}

export class MerchandiseService {
  /**
   * Get all active products with pagination
   */
  static async getAllProducts(page: number = 1, limit: number = 20) {
    const db = getDatabase();
    if (!db) {
      return { products: [], total: 0, page, limit, pages: 0 };
    }

    const offset = (page - 1) * limit;

    const total = await db('merchandise')
      .where('is_active', true)
      .count('* as count')
      .first();

    const products = await db('merchandise')
      .where('is_active', true)
      .orderBy('created_at', 'desc')
      .offset(offset)
      .limit(limit);

    const totalCount = total?.count || 0;

    return {
      products,
      total: totalCount,
      page,
      limit,
      pages: Math.ceil(totalCount / limit),
    };
  }

  /**
   * Get single product by ID
   */
  static async getProductById(productId: string) {
    const db = getDatabase();
    if (!db) return null;

    return db('merchandise')
      .where('id', productId)
      .where('is_active', true)
      .first();
  }

  /**
   * Create new product
   */
  static async createProduct(data: Product) {
    const db = getDatabase();
    if (!db) {
      throw new Error('Database not available');
    }

    const product = {
      id: uuidv4(),
      ...data,
      created_at: new Date(),
      updated_at: new Date(),
    };

    await db('merchandise').insert(product);
    return product;
  }

  /**
   * Update product
   */
  static async updateProduct(productId: string, data: Partial<Product>) {
    const db = getDatabase();
    if (!db) {
      throw new Error('Database not available');
    }

    const updateData = {
      ...data,
      updated_at: new Date(),
    };

    await db('merchandise')
      .where('id', productId)
      .update(updateData);

    return this.getProductById(productId);
  }

  /**
   * Delete (soft delete) product
   */
  static async deleteProduct(productId: string) {
    const db = getDatabase();
    if (!db) {
      throw new Error('Database not available');
    }

    await db('merchandise')
      .where('id', productId)
      .update({
        is_active: false,
        updated_at: new Date(),
      });

    return true;
  }

  /**
   * Search products by name or category
   */
  static async searchProducts(
    query: string = '',
    category?: string,
    page: number = 1,
    limit: number = 20
  ) {
    const db = getDatabase();
    if (!db) {
      return { products: [], total: 0, page, limit, pages: 0 };
    }

    const offset = (page - 1) * limit;

    let dbQuery = db('merchandise').where('is_active', true);

    if (query) {
      dbQuery = dbQuery.where('name', 'ilike', `%${query}%`);
    }

    if (category) {
      dbQuery = dbQuery.where('category', category);
    }

    const total = await dbQuery
      .clone()
      .count('* as count')
      .first();

    const products = await dbQuery
      .orderBy('created_at', 'desc')
      .offset(offset)
      .limit(limit);

    const totalCount = total?.count || 0;

    return {
      products,
      total: totalCount,
      page,
      limit,
      pages: Math.ceil(totalCount / limit),
    };
  }

  /**
   * Get products by category
   */
  static async getProductsByCategory(
    category: string,
    page: number = 1,
    limit: number = 20
  ) {
    const db = getDatabase();
    if (!db) {
      return { products: [], total: 0, page, limit, pages: 0 };
    }

    const offset = (page - 1) * limit;

    const total = await db('merchandise')
      .where('is_active', true)
      .where('category', category)
      .count('* as count')
      .first();

    const products = await db('merchandise')
      .where('is_active', true)
      .where('category', category)
      .orderBy('created_at', 'desc')
      .offset(offset)
      .limit(limit);

    const totalCount = total?.count || 0;

    return {
      products,
      total: totalCount,
      page,
      limit,
      pages: Math.ceil(totalCount / limit),
    };
  }

  /**
   * Update stock for multiple products
   */
  static async updateStock(updates: Array<{ id: string; quantity: number }>) {
    const db = getDatabase();
    if (!db) {
      throw new Error('Database not available');
    }

    const results = [];

    for (const update of updates) {
      await db('merchandise')
        .where('id', update.id)
        .update({
          stock_quantity: update.quantity,
          updated_at: new Date(),
        });
      results.push(update.id);
    }

    return results;
  }

  /**
   * Get all categories
   */
  static async getCategories() {
    const db = getDatabase();
    if (!db) return [];

    const categories = await db('merchandise')
      .where('is_active', true)
      .select('category')
      .distinct()
      .whereNotNull('category');

    return categories.map(c => c.category);
  }

  /**
   * Get product statistics
   */
  static async getProductStats() {
    const db = getDatabase();
    if (!db) {
      return { total: 0, active: 0, lowStock: 0 };
    }

    const total = await db('merchandise').count('* as count').first();
    const active = await db('merchandise')
      .where('is_active', true)
      .count('* as count')
      .first();
    const lowStock = await db('merchandise')
      .where('is_active', true)
      .where('stock_quantity', '<', 10)
      .count('* as count')
      .first();

    return {
      total: total?.count || 0,
      active: active?.count || 0,
      lowStock: lowStock?.count || 0,
    };
  }
}
