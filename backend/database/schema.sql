-- Kindora Backend Database Schema for Supabase
-- All tables with timestamps, foreign keys, and RLS policies

-- ============================================
-- 1. USERS TABLE (User Profile & Details)
-- ============================================
-- This table stores user profile information synced from Firebase Auth
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  full_name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  role VARCHAR(50) NOT NULL DEFAULT 'donor', -- donor, charity, admin, beneficiary
  profile_picture_url TEXT,
  bio TEXT,
  location VARCHAR(255),
  verified BOOLEAN DEFAULT FALSE,
  email_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  last_login TIMESTAMP WITH TIME ZONE,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_users_firebase_uid CHECK (firebase_uid != '')
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Update timestamp trigger for users table
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW() AT TIME ZONE 'UTC';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_users_updated_at();

-- ============================================
-- 2. CAMPAIGNS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  campaigner_name VARCHAR(255),
  category VARCHAR(100),
  campaign_category VARCHAR(100),
  target_amount DECIMAL(15, 2),
  raised_amount DECIMAL(15, 2) DEFAULT 0.00,
  image_url TEXT,
  user_id UUID NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_campaigns_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- 2. CHARITIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS charities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url TEXT,
  category VARCHAR(100),
  amount_raised DECIMAL(15, 2) DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. DONATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  campaign_id UUID,
  charity_id UUID,
  amount DECIMAL(15, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'LKR',
  payment_method VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'completed',
  donor_name VARCHAR(255),
  donor_email VARCHAR(255),
  donor_phone VARCHAR(20),
  transaction_id VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_donations_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_donations_campaign_id FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL,
  CONSTRAINT fk_donations_charity_id FOREIGN KEY (charity_id) REFERENCES charities(id) ON DELETE SET NULL
);

-- ============================================
-- 4. WALLETS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS wallets (
  wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  total_recharged DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  total_spent DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_wallets_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- 5. WALLET_TRANSACTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS wallet_transactions (
  transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL,
  type VARCHAR(10) NOT NULL CHECK (type IN ('credit', 'debit')),
  amount DECIMAL(15, 2) NOT NULL,
  reference_id VARCHAR(255),
  description TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_wallet_transactions_wallet_id FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id) ON DELETE CASCADE,
  CONSTRAINT positive_amount CHECK (amount > 0)
);

-- ============================================
-- 6. MESSAGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL,
  recipient_id UUID NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_messages_sender_id FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_recipient_id FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Campaigns indexes
CREATE INDEX idx_campaigns_user_id ON campaigns(user_id);
CREATE INDEX idx_campaigns_status ON campaigns(status);
CREATE INDEX idx_campaigns_category ON campaigns(category);
CREATE INDEX idx_campaigns_created_at ON campaigns(created_at DESC);

-- Donations indexes
CREATE INDEX idx_donations_user_id ON donations(user_id);
CREATE INDEX idx_donations_campaign_id ON donations(campaign_id);
CREATE INDEX idx_donations_charity_id ON donations(charity_id);
CREATE INDEX idx_donations_status ON donations(status);
CREATE INDEX idx_donations_created_at ON donations(created_at DESC);

-- Wallets indexes
CREATE INDEX idx_wallets_user_id ON wallets(user_id);

-- Wallet transactions indexes
CREATE INDEX idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_timestamp ON wallet_transactions(timestamp DESC);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(type);

-- Messages indexes
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX idx_messages_is_read ON messages(is_read);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- ============================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================

-- Update wallet updated_at on modification
CREATE OR REPLACE FUNCTION update_wallet_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_wallets_updated_at
BEFORE UPDATE ON wallets
FOR EACH ROW
EXECUTE FUNCTION update_wallet_updated_at();

-- Update campaign updated_at on modification
CREATE OR REPLACE FUNCTION update_campaign_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_campaigns_updated_at
BEFORE UPDATE ON campaigns
FOR EACH ROW
EXECUTE FUNCTION update_campaign_updated_at();

-- Update wallet totals and balance when transaction is inserted
CREATE OR REPLACE FUNCTION update_wallet_totals()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.type = 'debit' THEN
    UPDATE wallets
    SET total_spent = total_spent + NEW.amount,
        balance = balance - NEW.amount
    WHERE wallet_id = NEW.wallet_id;
  ELSIF NEW.type = 'credit' THEN
    UPDATE wallets
    SET total_recharged = total_recharged + NEW.amount,
        balance = balance + NEW.amount
    WHERE wallet_id = NEW.wallet_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_wallet_transactions_update
AFTER INSERT ON wallet_transactions
FOR EACH ROW
EXECUTE FUNCTION update_wallet_totals();

-- Update campaign raised_amount when donation is created
CREATE OR REPLACE FUNCTION update_campaign_raised_amount()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.campaign_id IS NOT NULL THEN
    UPDATE campaigns
    SET raised_amount = raised_amount + NEW.amount
    WHERE id = NEW.campaign_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_donations_update_campaign
AFTER INSERT ON donations
FOR EACH ROW
EXECUTE FUNCTION update_campaign_raised_amount();

-- Update charity amount_raised when donation is created
CREATE OR REPLACE FUNCTION update_charity_amount_raised()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.charity_id IS NOT NULL THEN
    UPDATE charities
    SET amount_raised = amount_raised + NEW.amount
    WHERE id = NEW.charity_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_donations_update_charity
AFTER INSERT ON donations
FOR EACH ROW
EXECUTE FUNCTION update_charity_amount_raised();

-- ============================================
-- TABLE COMMENTS (DOCUMENTATION)
-- ============================================

COMMENT ON TABLE campaigns IS 'Stores user-created campaigns for fundraising';
COMMENT ON TABLE charities IS 'Stores charity organizations';
COMMENT ON TABLE donations IS 'Logs all donations made by users';
COMMENT ON TABLE wallets IS 'Stores user wallet balances and recharge/spend history';
COMMENT ON TABLE wallet_transactions IS 'Logs all wallet transactions (deposits and withdrawals)';
COMMENT ON TABLE messages IS 'Stores messages between users';

COMMENT ON COLUMN campaigns.status IS 'Campaign status: active, completed, cancelled';
COMMENT ON COLUMN wallets.balance IS 'Current wallet balance in LKR';
COMMENT ON COLUMN wallets.total_recharged IS 'Total cumulative amount user has recharged';
COMMENT ON COLUMN wallets.total_spent IS 'Total cumulative amount user has spent';
COMMENT ON COLUMN wallet_transactions.type IS 'Transaction type: credit (deposit) or debit (withdrawal)';
COMMENT ON COLUMN wallet_transactions.reference_id IS 'Reference to campaign/donation/payment that triggered this transaction';
COMMENT ON COLUMN donations.payment_method IS 'Payment method used: wallet, stripe, card_payment, bank_transfer';
COMMENT ON COLUMN donations.status IS 'Donation status: pending, completed, failed, refunded';
