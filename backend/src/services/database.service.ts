import { knex } from 'knex';
import type { Knex } from 'knex';
import dotenv from 'dotenv';

dotenv.config();

let db: Knex;

export async function initializeDatabase() {
  // NOTE: Using Supabase REST API instead of direct PostgreSQL connection
  // All database operations go through supabase.service.ts
  console.log('✓ Database mode: Supabase REST API (no direct TCP connection)');
  return null;
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
