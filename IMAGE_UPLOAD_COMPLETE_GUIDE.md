# 📸 Complete Image Upload Fix - Step-by-Step Guide

## Phase 1: Clean Slate - Delete Current Table

### Step 1: Access Supabase Dashboard
1. Go to: https://supabase.com
2. Login with your Kindora account
3. Select your project (Kindora)
4. Navigate to **SQL Editor** (left panel)

### Step 2: Delete Existing Tables
Run this query to drop all products-related tables:

```sql
-- DROP ALL PRODUCT TABLES (This deletes all existing data)
DROP TABLE IF EXISTS product_orders CASCADE;
DROP TABLE IF EXISTS product_cart_items CASCADE;
DROP TABLE IF EXISTS product_reviews CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS merchandise CASCADE;

-- Verify they're deleted
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%product%' 
OR table_name = 'merchandise';
```

**⚠️ WARNING:** This will DELETE all existing product data. If you need to keep any data, export it first.

### Step 3: Verify Deletion
After running the query, you should see:
- ✅ Query executed successfully
- ✅ No tables returned in the verification query

---

## Phase 2: Create Fresh Schema

### Step 4: Create Merchandise Table with Proper Image Storage

Run this complete schema in Supabase SQL Editor:

```sql
-- ============================================
-- MERCHANDISE TABLE (Products)
-- ============================================
CREATE TABLE IF NOT EXISTS merchandise (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic Product Info
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category VARCHAR(100),
  sku VARCHAR(100) UNIQUE,
  
  -- Stock Management
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  
  -- Image Storage (CRITICAL!)
  image_url TEXT NOT NULL DEFAULT '',  -- URL from Supabase Storage
  image_bucket VARCHAR(100) DEFAULT 'Kindora',
  image_path TEXT,  -- Path in storage bucket
  
  -- Ratings
  average_rating DECIMAL(3, 2) DEFAULT 0.0,
  review_count INTEGER DEFAULT 0,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Create indexes for performance
CREATE INDEX idx_merchandise_category ON merchandise(category);
CREATE INDEX idx_merchandise_is_active ON merchandise(is_active);
CREATE INDEX idx_merchandise_created_at ON merchandise(created_at DESC);
CREATE INDEX idx_merchandise_name ON merchandise(name);

-- ============================================
-- PRODUCT REVIEWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS product_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES merchandise(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_product_reviews_product ON product_reviews(product_id);

-- ============================================
-- SHOPPING CART TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS shopping_cart (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES merchandise(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

CREATE INDEX idx_shopping_cart_user ON shopping_cart(user_id);

-- ============================================
-- ORDERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS product_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES merchandise(id) ON DELETE SET NULL,
  buyer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  total_amount DECIMAL(10, 2) NOT NULL,
  order_status VARCHAR(50) DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
  shipping_address JSON,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_product_orders_buyer ON product_orders(buyer_id);
CREATE INDEX idx_product_orders_status ON product_orders(order_status);

-- ============================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE merchandise ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_cart ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_orders ENABLE ROW LEVEL SECURITY;

-- Public read access to merchandise
CREATE POLICY "merchandise_public_read" ON merchandise
  FOR SELECT USING (is_active = true);

-- Admin write access (adjust based on your auth)
CREATE POLICY "merchandise_admin_write" ON merchandise
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "merchandise_admin_update" ON merchandise
  FOR UPDATE WITH CHECK (auth.role() = 'authenticated');

-- Shopping cart policies
CREATE POLICY "cart_user_access" ON shopping_cart
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "cart_user_insert" ON shopping_cart
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "cart_user_update" ON shopping_cart
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "cart_user_delete" ON shopping_cart
  FOR DELETE USING (user_id = auth.uid());
```

### Step 5: Verify Table Creation
Run this to confirm:

```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('merchandise', 'product_reviews', 'shopping_cart', 'product_orders');
```

You should see all 4 tables listed.

---

## Phase 3: Test Image Upload Flow

### Step 6: Get Admin Token
1. In admin panel, open **Developer Tools** (F12)
2. Go to **Application → Local Storage**
3. Find and copy the `access_token` value
4. Save it as you'll need it for testing

### Step 7: Test Upload with cURL

Run this command in PowerShell to upload a test image:

```powershell
# Test image upload
$token = "YOUR_ACCESS_TOKEN_HERE"  # Replace with token from Step 6
$imagePath = "C:\path\to\test\image.jpg"  # Use a real image on your computer

# Create multipart form data
$form = @{
    'image' = Get-Item -Path $imagePath
    'folder' = 'products'
}

# Make the request
$response = Invoke-WebRequest `
  -Uri "http://localhost:5000/api/storage/upload" `
  -Method POST `
  -Headers @{
    'Authorization' = "Bearer $token"
  } `
  -Form $form

# Display response
$response.Content | ConvertFrom-Json | Format-List

# Verify you get a URL response like:
# {
#   "success": true,
#   "url": "https://your-supabase-url.supabase.co/storage/v1/object/public/Kindora/products/...",
#   "fileName": "products_1710932400000_image.jpg",
#   "bucket": "Kindora"
# }
```

### Step 8: Create Product with Image URL

If Step 7 returned a URL, use it here:

```powershell
$token = "YOUR_ACCESS_TOKEN_HERE"
$imageUrl = "https://your-supabase-url.../Kindora/products/..." # From Step 7 response

$body = @{
    name = "Test T-Shirt"
    description = "A beautiful test t-shirt"
    price = 29.99
    stock_quantity = 10
    category = "apparel"
    image_url = $imageUrl  # CRITICAL: Use the actual URL from upload
} | ConvertTo-Json

$response = Invoke-WebRequest `
  -Uri "http://localhost:5000/api/merchandise" `
  -Method POST `
  -Headers @{
    'Authorization' = "Bearer $token"
    'Content-Type' = 'application/json'
  } `
  -Body $body

$response.Content | ConvertFrom-Json | Format-List
```

### Step 9: Verify in Supabase

1. Go to **Supabase Dashboard → Table Editor**
2. Select **merchandise** table
3. Check if your product appears with the `image_url` field populated
4. **IMPORTANT:** The `image_url` should be a full Supabase URL, not null or empty

---

## Phase 4: Test in Admin Panel

### Step 10: Upload via Admin Panel

1. Start the backend:
```bash
cd backend
npm start
```

2. In another terminal, start admin panel:
```bash
cd admin_panel
npm start
```

3. In admin panel UI:
   - Navigate to **Merchandise** section
   - Click **Add Product**
   - Fill in:
     - Product Name: "Kindora T-Shirt"
     - Price: 49.99
     - Stock: 20
     - Category: "apparel"
   - **Click file upload button**
   - Select an image file
   - Click **Save Product**

4. **Check results:**
   - Does "Add New Product" dialog show?
   - Does file upload work?
   - Does product appear in list?
   - **Does image show (not placeholder)?**

---

## 🔷 Phase 5: Debugging - If Image Still Doesn't Show

### Check 1: Verify API Response
Open browser DevTools (F12) → Network tab → Check the POST `/api/storage/upload` request:

Should see response like:
```json
{
  "success": true,
  "url": "https://xxxx.supabase.co/storage/v1/object/public/Kindora/products/products_1234567890_imagename.jpg",
  "fileName": "products_1234567890_imagename.jpg",
  "bucket": "Kindora"
}
```

**❌ If `url` is null or empty → Storage upload failed**

### Check 2: Verify Database
In Supabase SQL Editor:

```sql
SELECT id, name, image_url, created_at 
FROM merchandise 
ORDER BY created_at DESC 
LIMIT 5;
```

**❌ If `image_url` is NULL or empty → URL not stored**
**✅ If `image_url` has a full URL → Check if URL is accessible**

### Check 3: Verify Image URL Works
Copy the `image_url` from the database and paste it in browser address bar.

**❌ If image doesn't load → URL is broken or Supabase storage issue**
**✅ If image loads → Frontend display issue**

### Check 4: Frontend Display
In admin panel, inspect the product image element:

Press F12 → Elements tab → Find `<img>` tag

Check:
- `src` attribute has correct URL
- URL is not "undefined" or empty
- No CORS errors in Console tab

---

## 🎯 Critical Points for Image Storage

1. **Upload Endpoint Must Return URL:**
   ```typescript
   // ✅ CORRECT - Returns URL
   res.json({ success: true, url: publicUrl })
   
   // ❌ WRONG - Returns null
   res.json({ success: true, url: null })
   ```

2. **Product Must Store URL:**
   ```typescript
   // ✅ CORRECT - Stores the URL
   await supabase.from('merchandise').insert({ image_url: uploadedUrl })
   
   // ❌ WRONG - Stores empty
   await supabase.from('merchandise').insert({ image_url: '' })
   ```

3. **Frontend Must Display URL:**
   ```jsx
   // ✅ CORRECT - Shows uploaded image
   <img src={product.image_url} alt={product.name} />
   
   // ❌ WRONG - Shows placeholder
   <img src={product.image_url || placeholderUrl} alt={product.name} />
   ```

---

## 📋 Complete Checklist

- [ ] Deleted all old product tables
- [ ] Created fresh merchandise table
- [ ] Backend server running (`npm start`)
- [ ] Storage endpoint accessible (`/api/storage/upload`)
- [ ] Merchandise endpoint working (`/api/merchandise`)
- [ ] Can upload image via cURL
- [ ] Image URL returned from upload
- [ ] Product created in database
- [ ] `image_url` field is populated (not null)
- [ ] URL is accessible (paste in browser)
- [ ] Image displays in admin panel
- [ ] **Not showing placeholder anymore! ✅**

---

## 🚀 Next Steps

1. **Delete old tables** (Phase 1)
2. **Run new schema** (Phase 2)
3. **Test with cURL** (Phase 3, Steps 7-8)
4. **Test in admin panel** (Phase 4)
5. **Debug if needed** (Phase 5)

Let me know which step you're on and we'll fix any issues!
