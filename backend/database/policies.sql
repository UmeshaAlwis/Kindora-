-- Kindora Row Level Security (RLS) Policies
-- These policies ensure users can only access their own data

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE charities ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_volunteers ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USERS POLICIES
-- ============================================

-- Users can view their own profile
CREATE POLICY "users_view_own" ON users
FOR SELECT USING (auth.uid() = id);

-- Users can view other profiles (public)
CREATE POLICY "users_view_public" ON users
FOR SELECT USING (TRUE);

-- Users can update their own profile
CREATE POLICY "users_update_own" ON users
FOR UPDATE USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================
-- CAMPAIGNS POLICIES
-- ============================================

-- Users can view all campaigns (public)
CREATE POLICY "campaigns_view_all" ON campaigns
FOR SELECT USING (TRUE);

-- Users can create campaigns
CREATE POLICY "campaigns_create" ON campaigns
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own campaigns
CREATE POLICY "campaigns_update_own" ON campaigns
FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own campaigns
CREATE POLICY "campaigns_delete_own" ON campaigns
FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- CAMPAIGN_VOLUNTEERS POLICIES
-- ============================================
-- Volunteers can view only their own joined rows
CREATE POLICY "campaign_volunteers_view_own" ON campaign_volunteers
FOR SELECT USING (auth.uid() = user_id);

-- Volunteers can join/create their own join row
CREATE POLICY "campaign_volunteers_insert_own" ON campaign_volunteers
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Volunteers can leave (delete) their own join row
CREATE POLICY "campaign_volunteers_delete_own" ON campaign_volunteers
FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- CHARITIES POLICIES
-- ============================================

-- Everyone can view all charities
CREATE POLICY "charities_view_all" ON charities
FOR SELECT USING (TRUE);

-- ============================================
-- DONATIONS POLICIES
-- ============================================

-- Users can view all donations (public)
CREATE POLICY "donations_view_all" ON donations
FOR SELECT USING (TRUE);

-- Authenticated users can create donations
CREATE POLICY "donations_create" ON donations
FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- ============================================
-- WALLETS POLICIES
-- ============================================

-- Users can only view their own wallet
CREATE POLICY "wallets_view_own" ON wallets
FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own wallet (via functions only)
CREATE POLICY "wallets_update_own" ON wallets
FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Wallets are created by functions/backend only
CREATE POLICY "wallets_insert_disabled" ON wallets
FOR INSERT WITH CHECK (FALSE);

-- ============================================
-- WALLET_TRANSACTIONS POLICIES
-- ============================================

-- Users can only view transactions from their own wallet
CREATE POLICY "wallet_transactions_view_own" ON wallet_transactions
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM wallets
    WHERE wallets.wallet_id = wallet_transactions.wallet_id
    AND wallets.user_id = auth.uid()
  )
);

-- Transactions are created by functions/backend only
CREATE POLICY "wallet_transactions_insert_disabled" ON wallet_transactions
FOR INSERT WITH CHECK (FALSE);

-- ============================================
-- MESSAGES POLICIES
-- ============================================

-- Users can view their own sent messages
CREATE POLICY "messages_view_sent" ON messages
FOR SELECT USING (auth.uid() = sender_id);

-- Users can view their own received messages
CREATE POLICY "messages_view_received" ON messages
FOR SELECT USING (auth.uid() = recipient_id);

-- Authenticated users can send messages
CREATE POLICY "messages_create" ON messages
FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Users can mark their received messages as read
CREATE POLICY "messages_update_received" ON messages
FOR UPDATE USING (auth.uid() = recipient_id)
WITH CHECK (auth.uid() = recipient_id);

-- ============================================
-- NOTIFICATIONS POLICIES
-- ============================================

-- Users can view their own notifications
CREATE POLICY "notifications_view_own" ON notifications
FOR SELECT USING (auth.uid() = user_id);

-- Users can mark their notifications as read
CREATE POLICY "notifications_update_own" ON notifications
FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- SECURE RLS SETUP FUNCTIONS
-- ============================================

-- Function to safely initialize user wallet when they sign up
CREATE OR REPLACE FUNCTION create_wallet_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO wallets (user_id, balance, total_recharged, total_spent)
  VALUES (NEW.id, 0, 0, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create wallet when user signs up
CREATE TRIGGER trigger_create_wallet_on_signup
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION create_wallet_for_user();

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

-- Grant usage on sequences
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Grant table permissions (row-level security will enforce row-level access)
GRANT SELECT, INSERT, UPDATE, DELETE ON campaigns TO authenticated;
GRANT SELECT ON charities TO authenticated;
GRANT SELECT, INSERT ON donations TO authenticated;
GRANT SELECT, UPDATE ON wallets TO authenticated;
GRANT SELECT ON wallet_transactions TO authenticated;
GRANT SELECT, INSERT, UPDATE ON messages TO authenticated;
GRANT SELECT, INSERT, UPDATE ON notifications TO authenticated;

-- Anonymous users can only view public data
GRANT SELECT ON campaigns TO anon;
GRANT SELECT ON charities TO anon;
GRANT SELECT ON donations TO anon;
