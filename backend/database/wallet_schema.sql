-- Create wallets table for user wallet balances
CREATE TABLE IF NOT EXISTS wallets (
  wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  total_recharged DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  total_spent DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_wallets_user_id FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create wallet_transactions table for transaction history
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

-- Create indexes for better query performance
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_timestamp ON wallet_transactions(timestamp DESC);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(type);

-- Create trigger to auto-update wallet updated_at timestamp
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

-- Create trigger to auto-update total_spent when transaction is inserted
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

-- Add comment to document the tables
COMMENT ON TABLE wallets IS 'Stores user wallet balances and recharge/spend history';
COMMENT ON TABLE wallet_transactions IS 'Logs all wallet transactions (deposits and withdrawals)';
COMMENT ON COLUMN wallets.balance IS 'Current wallet balance in LKR';
COMMENT ON COLUMN wallets.total_recharged IS 'Total amount user has recharged';
COMMENT ON COLUMN wallets.total_spent IS 'Total amount user has spent';
COMMENT ON COLUMN wallet_transactions.type IS 'Transaction type: credit (deposit) or debit (withdrawal)';
COMMENT ON COLUMN wallet_transactions.reference_id IS 'Reference to campaign/donation/payment that triggered this transaction';
