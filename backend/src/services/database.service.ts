import { knex } from 'knex';
import type { Knex } from 'knex';
import dotenv from 'dotenv';

dotenv.config();

let db: Knex;

export async function initializeDatabase() {
  try {
    db = knex({
      client: 'pg',
      connection: {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT || '5432'),
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || 'password',
        database: process.env.DB_NAME || 'kindora',
      },
      pool: { min: 2, max: 10 },
    });

    // Test connection
    await db.raw('SELECT 1');
    console.log('✓ Database connection successful');

    // Run migrations if needed
    // await runMigrations();

    return db;
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.warn('⚠️  Database connection failed. Running in offline mode.');
      console.warn('Make sure PostgreSQL is running on localhost:5432');
      // Return a mock database object for development
      return null;
    }
    console.error('Database initialization error:', error);
    throw error;
  }
}

export function getDatabase() {
  if (!db) {
    if (process.env.NODE_ENV === 'development') {
      console.warn('⚠️  Database not available in offline mode');
      return null;
    }
    throw new Error('Database not initialized');
  }
  return db;
}

export async function closeDatabase() {
  if (db) {
    await db.destroy();
  }
}
