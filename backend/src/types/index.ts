// User Types
export interface User {
  user_id: string;
  email: string;
  full_name: string;
  phone_number?: string;
  role: 'donor' | 'charity' | 'admin' | 'beneficiary';
  location?: string;
  profile_image_url?: string;
  bio?: string;
  language_preference?: string;
  email_verified: boolean;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
  last_login?: Date;
}

// Charity Types
export interface Charity {
  charity_id: string;
  user_id: string;
  name: string;
  description?: string;
  category?: string;
  registration_number: string;
  contact_info?: string;
  verification_status: 'pending' | 'verified' | 'rejected';
  documents_url?: string[];
  logo_url?: string;
  website_url?: string;
  social_media_links?: Record<string, string>;
  total_raised: number;
  donor_count: number;
  created_at: Date;
  updated_at: Date;
}

// Campaign Types
export interface Campaign {
  campaign_id: string;
  charity_id: string;
  title: string;
  description: string;
  category?: string;
  target_amount: number;
  current_amount: number;
  donor_count: number;
  status: 'active' | 'completed' | 'closed' | 'paused';
  beneficiary_details?: string;
  beneficiary_location?: string;
  image_url?: string;
  gallery_urls?: string[];
  start_date: Date;
  end_date?: Date;
  created_at: Date;
  updated_at: Date;
  progress: number; // Percentage
}

// Donation Types
export interface Donation {
  donation_id: string;
  donor_id: string;
  campaign_id: string;
  amount: number;
  payment_method: 'card' | 'wallet' | 'bank_transfer' | 'stripe' | 'payhere' | 'crypto';
  transaction_id?: string;
  status: 'success' | 'failed' | 'pending' | 'refunded';
  donation_type: 'one-time' | 'recurring';
  recurring_frequency?: 'daily' | 'weekly' | 'monthly' | 'yearly';
  message?: string;
  is_anonymous: boolean;
  timestamp: Date;
  receipt_url?: string;
}

// Wallet Types
export interface Wallet {
  wallet_id: string;
  user_id: string;
  balance: number;
  total_recharged: number;
  total_spent: number;
  created_at: Date;
  updated_at: Date;
}

export interface WalletTransaction {
  transaction_id: string;
  wallet_id: string;
  type: 'credit' | 'debit';
  amount: number;
  reference_id?: string;
  description: string;
  timestamp: Date;
}

// Message Types
export interface Message {
  message_id: string;
  sender_id: string;
  receiver_id: string;
  campaign_id?: string;
  content: string;
  attachment_url?: string;
  timestamp: Date;
  read_status: boolean;
  read_at?: Date;
}

// Gamification Types
export interface Gamification {
  user_id: string;
  total_points: number;
  badge_ids?: string[];
  donor_level: string;
  achievements?: any[];
  total_donations: number;
  streak_days: number;
  created_at: Date;
  updated_at: Date;
}

// Authentication Types
export interface AuthPayload {
  user_id: string;
  email: string;
  role: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  full_name: string;
  role: 'donor' | 'charity' | 'admin' | 'beneficiary';
  phone_number?: string;
  firebase_uid?: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  user: User;
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  pages: number;
}
