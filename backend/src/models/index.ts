// User Model
export interface UserModel {
  user_id: string;
  email: string;
  password_hash: string;
  full_name: string;
  phone_number?: string;
  role: 'donor' | 'charity' | 'admin' | 'beneficiary';
  location?: string;
  profile_image_url?: string;
  bio?: string;
  language_preference: string;
  email_verified: boolean;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
  last_login?: Date;
}

// Campaign Model
export interface CampaignModel {
  campaign_id: string;
  charity_id: string;
  title: string;
  description: string;
  category?: string;
  target_amount: number;
  current_amount: number;
  donor_count: number;
  beneficiary_details?: string;
  beneficiary_location?: string;
  status: 'active' | 'completed' | 'closed' | 'paused';
  image_url?: string;
  gallery_urls?: string[];
  start_date: Date;
  end_date?: Date;
  created_at: Date;
  updated_at: Date;
}

// Donation Model
export interface DonationModel {
  donation_id: string;
  donor_id: string;
  campaign_id: string;
  amount: number;
  payment_method: 'card' | 'wallet' | 'bank_transfer' | 'stripe' | 'payhere' | 'crypto';
  transaction_id?: string;
  status: 'success' | 'failed' | 'pending' | 'refunded';
  donation_type: 'one-time' | 'recurring';
  recurring_frequency?: 'daily' | 'weekly' | 'monthly' | 'yearly';
  next_donation_date?: Date;
  message?: string;
  is_anonymous: boolean;
  timestamp: Date;
  receipt_url?: string;
}

// Charity Model
export interface CharityModel {
  charity_id: string;
  user_id: string;
  name: string;
  description?: string;
  category?: string;
  registration_number: string;
  contact_info?: string;
  verification_status: 'pending' | 'verified' | 'rejected';
  verification_date?: Date;
  verified_by?: string;
  documents_url?: string[];
  logo_url?: string;
  website_url?: string;
  social_media_links?: Record<string, string>;
  total_raised: number;
  donor_count: number;
  impact_stories?: any[];
  created_at: Date;
  updated_at: Date;
}

// Message Model
export interface MessageModel {
  message_id: string;
  sender_id: string;
  receiver_id: string;
  campaign_id?: string;
  content: string;
  attachment_url?: string;
  timestamp: Date;
  read_status: boolean;
  read_at?: Date;
  edited_at?: Date;
}

// Event Model
export interface EventModel {
  event_id: string;
  charity_id: string;
  title: string;
  description?: string;
  location?: string;
  event_date: Date;
  capacity?: number;
  image_url?: string;
  rsvp_count: number;
  created_at: Date;
}

// Product Model (Merchandise)
export interface ProductModel {
  product_id: string;
  charity_id: string;
  name: string;
  description?: string;
  price: number;
  images_url?: string[];
  stock_quantity: number;
  category?: string;
  sku?: string;
  created_at: Date;
  updated_at: Date;
}

// Order Model
export interface OrderModel {
  order_id: string;
  user_id: string;
  total_amount: number;
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled';
  shipping_address?: any;
  created_at: Date;
  updated_at: Date;
}

// Gamification Model
export interface GamificationModel {
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
