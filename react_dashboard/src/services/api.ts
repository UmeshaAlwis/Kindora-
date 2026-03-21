import axios, { AxiosInstance, AxiosError } from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add request interceptor
    this.client.interceptors.request.use((config) => {
      const token = localStorage.getItem('access_token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // Add response interceptor
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        if (error.response?.status === 401) {
          // Token expired, redirect to login
          localStorage.removeItem('access_token');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Auth Endpoints
  login(email: string, password: string) {
    return this.client.post('/auth/login', { email, password });
  }

  register(data: any) {
    return this.client.post('/auth/register', data);
  }

  getCurrentUser() {
    return this.client.get('/auth/me');
  }

  // Users Endpoints
  getUsers(page: number = 1, limit: number = 20) {
    return this.client.get('/users', { params: { page, limit } });
  }

  getUserById(userId: string) {
    return this.client.get(`/users/${userId}`);
  }

  updateUser(userId: string, data: any) {
    return this.client.put(`/users/${userId}`, data);
  }

  // Charities Endpoints
  getCharities(page: number = 1, status?: string) {
    return this.client.get('/charities', {
      params: { page, status },
    });
  }

  getCharityById(charityId: string) {
    return this.client.get(`/charities/${charityId}`);
  }

  verifyCharity(charityId: string) {
    return this.client.post(`/charities/${charityId}/verify`, {});
  }

  rejectCharity(charityId: string, reason: string) {
    return this.client.post(`/charities/${charityId}/reject`, { reason });
  }

  // Campaigns Endpoints
  getCampaigns(page: number = 1, status?: string) {
    return this.client.get('/campaigns', {
      params: { page, status },
    });
  }

  getCampaignById(campaignId: string) {
    return this.client.get(`/campaigns/${campaignId}`);
  }

  approveCampaign(campaignId: string) {
    return this.client.post(`/campaigns/${campaignId}/approve`, {});
  }

  rejectCampaign(campaignId: string, reason: string) {
    return this.client.post(`/campaigns/${campaignId}/reject`, { reason });
  }

  // Analytics Endpoints
  getAnalytics(startDate?: string, endDate?: string) {
    return this.client.get('/analytics', {
      params: { startDate, endDate },
    });
  }

  getDonationStats() {
    return this.client.get('/analytics/donations');
  }

  getUserStats() {
    return this.client.get('/analytics/users');
  }

  // Scam Reports Endpoints
  getScamReports(status?: string) {
    return this.client.get('/scam-reports', { params: { status } });
  }

  reviewScamReport(reportId: string, verified: boolean, notes: string) {
    return this.client.post(`/scam-reports/${reportId}/review`, {
      verified,
      notes,
    });
  }

  // Merchandise/Products Endpoints
  getProducts(page: number = 1, limit: number = 20) {
    return this.client.get('/merchandise', { params: { page, limit } });
  }

  getProductById(productId: string) {
    return this.client.get(`/merchandise/${productId}`);
  }

  createProduct(data: any) {
    return this.client.post('/merchandise', data);
  }

  updateProduct(productId: string, data: any) {
    return this.client.put(`/merchandise/${productId}`, data);
  }

  deleteProduct(productId: string) {
    return this.client.delete(`/merchandise/${productId}`);
  }

  searchProducts(query: string, category?: string, page: number = 1, limit: number = 20) {
    return this.client.get('/merchandise/search', {
      params: { query, category, page, limit },
    });
  }

  getProductsByCategory(category: string, page: number = 1, limit: number = 20) {
    return this.client.get(`/merchandise/category/${category}`, {
      params: { page, limit },
    });
  }

  updateProductStock(updates: Array<{ productId: string; quantityChange: number }>) {
    return this.client.post('/merchandise/stock/update', { updates });
  }

  // Storage/Upload Endpoints
  uploadImage(file: File, folder: string = 'products') {
    const formData = new FormData();
    formData.append('image', file);
    formData.append('folder', folder);

    return this.client.post('/storage/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  }

  deleteImage(fileName: string, bucket?: string) {
    return this.client.delete('/storage/delete', {
      data: { fileName, bucket },
    });
  }
}

export default new ApiClient();
export { ApiClient };
