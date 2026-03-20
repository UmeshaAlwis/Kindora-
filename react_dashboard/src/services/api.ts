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
}

export default new ApiClient();
