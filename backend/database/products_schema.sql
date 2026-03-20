-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_url TEXT,
  category VARCHAR(100),
  stock_quantity INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  average_rating DECIMAL(3, 2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Create product reviews table
CREATE TABLE IF NOT EXISTS product_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create product cart items table
CREATE TABLE IF NOT EXISTS product_cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Create product orders table
CREATE TABLE IF NOT EXISTS product_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE SET NULL,
  buyer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  order_status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_product_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_product_reviews_reviewer_id ON product_reviews(reviewer_id);
CREATE INDEX idx_product_cart_user_id ON product_cart_items(user_id);
CREATE INDEX idx_product_orders_buyer_id ON product_orders(buyer_id);

-- Enable RLS on products table
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- RLS Policies for products (public read, authenticated write)
CREATE POLICY "Products are viewable by everyone" 
  ON products FOR SELECT 
  USING (is_active = true);

CREATE POLICY "Authenticated users can insert products" 
  ON products FOR INSERT 
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Product creators can update their products" 
  ON products FOR UPDATE 
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Product creators can delete their products" 
  ON products FOR DELETE 
  USING (auth.uid() = created_by);

-- Enable RLS on product reviews
ALTER TABLE product_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Product reviews are viewable by everyone" 
  ON product_reviews FOR SELECT 
  USING (true);

CREATE POLICY "Users can insert their own reviews" 
  ON product_reviews FOR INSERT 
  WITH CHECK (auth.uid() = reviewer_id);

CREATE POLICY "Users can update their own reviews" 
  ON product_reviews FOR UPDATE 
  USING (auth.uid() = reviewer_id)
  WITH CHECK (auth.uid() = reviewer_id);

-- Enable RLS on product cart items
ALTER TABLE product_cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own cart" 
  ON product_cart_items FOR ALL 
  USING (auth.uid() = user_id);

-- Enable RLS on product orders
ALTER TABLE product_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own orders" 
  ON product_orders FOR SELECT 
  USING (auth.uid() = buyer_id);

CREATE POLICY "Users can insert orders for themselves" 
  ON product_orders FOR INSERT 
  WITH CHECK (auth.uid() = buyer_id);

-- Create function to update product rating
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET 
    average_rating = COALESCE((
      SELECT AVG(rating) FROM product_reviews WHERE product_id = NEW.product_id
    ), 0),
    review_count = (
      SELECT COUNT(*) FROM product_reviews WHERE product_id = NEW.product_id
    )
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for product reviews
CREATE TRIGGER update_product_rating_trigger
AFTER INSERT OR UPDATE OR DELETE ON product_reviews
FOR EACH ROW
EXECUTE FUNCTION update_product_rating();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER product_reviews_updated_at
BEFORE UPDATE ON product_reviews
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER product_orders_updated_at
BEFORE UPDATE ON product_orders
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- Grant permissions
GRANT ALL ON products TO authenticated;
GRANT ALL ON product_reviews TO authenticated;
GRANT ALL ON product_cart_items TO authenticated;
GRANT ALL ON product_orders TO authenticated;
