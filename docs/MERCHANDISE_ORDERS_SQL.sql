CREATE TABLE IF NOT EXISTS merchandise_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  merchandise_id UUID NOT NULL REFERENCES merchandise(id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(12, 2) NOT NULL,
  total_amount DECIMAL(12, 2) NOT NULL,
  payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('wallet', 'card')),
  shipping_address TEXT,
  receiver_phone VARCHAR(20),
  status VARCHAR(30) NOT NULL DEFAULT 'success',
  transaction_id VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE merchandise_orders
  ADD COLUMN IF NOT EXISTS shipping_address TEXT,
  ADD COLUMN IF NOT EXISTS receiver_phone VARCHAR(20);

CREATE INDEX IF NOT EXISTS idx_merchandise_orders_user_id
  ON merchandise_orders (user_id);
CREATE INDEX IF NOT EXISTS idx_merchandise_orders_merchandise_id
  ON merchandise_orders (merchandise_id);
CREATE INDEX IF NOT EXISTS idx_merchandise_orders_created_at
  ON merchandise_orders (created_at DESC);
