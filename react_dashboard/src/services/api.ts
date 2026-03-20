import axios, { AxiosError, AxiosInstance } from 'axios';

const API_BASE_URL =
  (import.meta as any).env?.VITE_API_URL || 'http://localhost:5001/api';

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

  adminLogin(email: string, password: string) {
    return this.client.post('/products/admin/login', { email, password });
  }

  getProducts() {
    return this.client.get('/products/admin');
  }

  createProduct(data: {
    name: string;
    description?: string;
    price: number;
    stock_quantity: number;
    category: string;
    image_url?: string;
  }) {
    return this.client.post('/products/admin', data);
  }

  uploadProductImage(file: File) {
    const formData = new FormData();
    formData.append('image', file);
    return this.client.post('/products/admin/upload-image', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  }

  getAdminUsers() {
    return this.client.get('/admin/users');
  }

  updateUserStatus(userId: string, is_active: boolean) {
    return this.client.patch(`/admin/users/${userId}/status`, { is_active });
  }

  getAdminCampaigns() {
    return this.client.get('/admin/campaigns');
  }

  updateCampaignStatus(campaignId: string, status: string) {
    return this.client.patch(`/admin/campaigns/${campaignId}/status`, { status });
  }

  getAdminBeneficiaryCampaigns() {
    return this.client.get('/admin/beneficiary-campaigns');
  }

  updateBeneficiaryCampaignStatus(campaignId: string, status: string) {
    return this.client.patch(`/admin/beneficiary-campaigns/${campaignId}/status`, {
      status,
    });
  }

  getAdminMerchandise() {
    return this.client.get('/admin/merchandise');
  }

  updateMerchandiseStatus(id: string, is_active: boolean) {
    return this.client.patch(`/admin/merchandise/${id}/status`, { is_active });
  }

  deleteMerchandise(id: string) {
    return this.client.delete(`/admin/merchandise/${id}`);
  }

  getAdminFeedPosts(limit = 200) {
    return this.client.get(`/admin/feed-posts?limit=${limit}`);
  }

  deleteAdminFeedPost(postId: string) {
    return this.client.delete(`/admin/feed-posts/${postId}`);
  }
}

export default new ApiClient();
