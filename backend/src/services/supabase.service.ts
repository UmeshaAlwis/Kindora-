import axios, { AxiosInstance } from 'axios';
import dotenv from 'dotenv';

dotenv.config();

class SupabaseClient {
  private client: AxiosInstance;
  private url: string;
  private serviceRoleKey: string;

  constructor() {
    this.url = process.env.SUPABASE_URL || '';
    this.serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

    if (!this.url || !this.serviceRoleKey) {
      throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
    }

    this.client = axios.create({
      baseURL: `${this.url}/rest/v1`,
      headers: {
        'Authorization': `Bearer ${this.serviceRoleKey}`,
        'apikey': this.serviceRoleKey,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
    });
  }

  /**
   * Generic SELECT query
   */
  async select<T>(
    table: string,
    options?: {
      select?: string;
      filters?: Record<string, any>;
      limit?: number;
      offset?: number;
      orderBy?: { column: string; ascending?: boolean };
    }
  ): Promise<T[]> {
    try {
      let url = `/${table}`;
      const params: Record<string, any> = {};

      if (options?.select) {
        params.select = options.select;
      }

      if (options?.filters) {
        Object.entries(options.filters).forEach(([key, value]) => {
          params[key] = `eq.${value}`;
        });
      }

      if (options?.limit) {
        params.limit = options.limit;
      }

      if (options?.offset) {
        params.offset = options.offset;
      }

      if (options?.orderBy) {
        const direction = options.orderBy.ascending !== false ? 'asc' : 'desc';
        params.order = `${options.orderBy.column}.${direction}`;
      }

      console.log(`[Supabase] SELECT from ${table}:`, { params });
      const response = await this.client.get(url, { params });
      console.log(`[Supabase] SELECT response: ${response.data.length} rows`);
      return response.data;
    } catch (error: any) {
      const errorMsg = error.response?.data?.message || error.response?.data?.error || error.message;
      console.error(`[Supabase] SELECT error:`, {
        table,
        status: error.response?.status,
        message: errorMsg,
        url: error.config?.url,
        params: error.config?.params,
      });
      throw new Error(`SELECT from ${table} failed: ${errorMsg || error.message}`);
    }
  }

  /**
   * Generic INSERT
   */
  async insert<T>(table: string, data: any): Promise<T> {
    try {
      console.log(`[Supabase] Inserting into ${table}:`, JSON.stringify(data, null, 2));
      const response = await this.client.post(`/${table}`, data);
      return response.data[0] || response.data;
    } catch (error: any) {
      const errorMsg = error.response?.data?.message || error.response?.data?.error || error.message;
      console.error(`[Supabase] INSERT error details:`, {
        table,
        status: error.response?.status,
        message: errorMsg,
        data: error.response?.data,
      });
      throw new Error(`INSERT into ${table} failed: ${errorMsg || error.message}`);
    }
  }

  /**
   * Generic UPDATE
   */
  async update<T>(table: string, data: any, filter: Record<string, any>): Promise<T> {
    try {
      let url = `/${table}`;
      const params: Record<string, any> = {};

      Object.entries(filter).forEach(([key, value]) => {
        params[key] = `eq.${value}`;
      });

      const response = await this.client.patch(url, data, { params });
      return response.data[0] || response.data;
    } catch (error) {
      throw new Error(`UPDATE ${table} failed: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Generic DELETE
   */
  async delete(table: string, filter: Record<string, any>): Promise<void> {
    try {
      let url = `/${table}`;
      const params: Record<string, any> = {};

      Object.entries(filter).forEach(([key, value]) => {
        params[key] = `eq.${value}`;
      });

      await this.client.delete(url, { params });
    } catch (error) {
      throw new Error(`DELETE from ${table} failed: ${error instanceof Error ? error.message : error}`);
    }
  }

  /**
   * Raw RPC call (for stored procedures)
   */
  async rpc(functionName: string, params?: any): Promise<any> {
    try {
      const response = await this.client.post(`/rpc/${functionName}`, params || {});
      return response.data;
    } catch (error) {
      throw new Error(`RPC call to ${functionName} failed: ${error instanceof Error ? error.message : error}`);
    }
  }
}

// Export singleton instance
export const supabase = new SupabaseClient();
