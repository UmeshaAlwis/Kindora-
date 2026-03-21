# 🚀 REAL PHOTO UPLOAD - STEP-BY-STEP PRACTICAL GUIDE

## ⚠️ Important: Image Upload Is Now Fully Implemented!

The storage controller and routes have just been created. You now have:
- ✅ `backend/src/controllers/storage.controller.ts` - Handles uploads
- ✅ `backend/src/routes/storage.routes.ts` - Routes for upload endpoints
- ✅ Backend properly configured in `index.ts`

---

## PHASE 1: Prepare Supabase (5 minutes)

### Step 1.1: Delete Old Merchandise Table
1. Go to **https://supabase.com**
2. Log in with your account
3. Select your **Kindora** project
4. Click **SQL Editor** (left sidebar)
5. Click **New Query** button
6. Paste and run this:

```sql
DROP TABLE IF EXISTS product_orders CASCADE;
DROP TABLE IF EXISTS product_cart_items CASCADE;
DROP TABLE IF EXISTS product_reviews CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS merchandise CASCADE;
```

✅ Wait for: "Command completed successfully"

### Step 1.2: Create Fresh Merchandise Table
Paste this in a **new SQL query**:

```sql
-- Create merchandise table
CREATE TABLE merchandise (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category VARCHAR(100),
  stock_quantity INTEGER DEFAULT 0,
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  average_rating DECIMAL(3, 2) DEFAULT 0.0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create product_reviews table
CREATE TABLE product_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES merchandise(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create shopping_cart table
CREATE TABLE shopping_cart (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  product_id UUID NOT NULL REFERENCES merchandise(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Create product_orders table
CREATE TABLE product_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES merchandise(id) ON DELETE SET NULL,
  buyer_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  order_status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

✅ Wait for: "Command completed successfully"

### Step 1.3: Verify Tables Created
Run this query:

```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('merchandise', 'product_reviews', 'shopping_cart', 'product_orders');
```

✅ You should see 4 tables listed.

---

## PHASE 2: Start Backend (5 minutes)

### Step 2.1: Install Dependencies (if first time)
Open PowerShell and run:

```powershell
cd "c:\Users\Asus\Desktop\Kindora-\backend"
npm install
```

### Step 2.2: Start Backend Server
In PowerShell:

```powershell
cd "c:\Users\Asus\Desktop\Kindora-\backend"
npm start
```

✅ Wait for message:
```
╔════════════════════════════════════╗
║  Kindora Backend Server Started    ║
║  Port: 5000                        ║
║  API: http://localhost:5000/api    ║
╚════════════════════════════════════╝
```

---

## PHASE 3: Test Upload Endpoint (5 minutes)

### Step 3.1: Get Your Auth Token

**Method A: From Admin Panel**
1. Open admin panel: http://localhost:3000 (or whatever port)
2. Log in
3. Open browser **DevTools** (Press F12)
4. Go to **Application → Local Storage**
5. Find `access_token` value
6. Copy it and save somewhere temporarily

**Method B: Get Token from Backend**
1. In PowerShell, run this to get a token:

```powershell
# First, register/login to get token
$loginBody = @{
    email = "admin@kindora.com"
    password = "your_password_here"  # Use admin password
} | ConvertTo-Json

$response = Invoke-WebRequest `
  -Uri "http://localhost:5000/api/auth/login" `
  -Method POST `
  -Headers @{'Content-Type' = 'application/json'} `
  -Body $loginBody

$token = ($response.Content | ConvertFrom-Json).data.access_token
Write-Host "Token: $token"
```

### Step 3.2: Test Upload with Real Image

**Find a test image:**
- Use any image file on your computer
- For example: `C:\Users\Asus\Pictures\test.jpg`
- Or download one: http://unsplash.com (pick any image)

**In PowerShell, run this:**

```powershell
# ⚠️ REPLACE THESE VALUES:
$imagePath = "C:\path\to\your\image.jpg"  # Change to your image
$token = "YOUR_TOKEN_HERE"               # Paste token from Step 3.1

# Create the form data
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
  -Form $form `
  -ErrorAction SilentlyContinue

# Show the response
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response:"
$responseData = $response.Content | ConvertFrom-Json
$responseData | Format-List
```

**Expected Response:**
```json
{
  "success": true,
  "url": "https://xxxx.supabase.co/storage/v1/object/public/Kindora/products/...",
  "fileName": "products_1234567890_xxx_imagename.jpg",
  "bucket": "Kindora"
}
```

**❌ If you see errors:**

| Error | Solution |
|-------|----------|
| "No file provided" | Make sure image path is correct |
| "Cannot find path" | Image file doesn't exist - verify path |
| "401 Unauthorized" | Token is invalid or expired - get new token |
| "Supabase configuration missing" | Missing env variables in `.env` |

### Step 3.3: Save the Image URL
Copy the `url` value from the response. You'll use it in the next step.

Example:
```
https://xxxx.supabase.co/storage/v1/object/public/Kindora/products/products_1234567890_abc_test.jpg
```

---

## PHASE 4: Create Product with Image (5 minutes)

### Step 4.1: Create Product
Replace the values and run this in PowerShell:

```powershell
$token = "YOUR_TOKEN_HERE"  # From Step 3.1
$imageUrl = "PASTE_URL_HERE"  # From Step 3.3

$body = @{
    name = "Kindora White T-Shirt"
    description = "Official Kindora merchandise - comfortable and stylish"
    price = 49.99
    stock_quantity = 20
    category = "apparel"
    image_url = $imageUrl
} | ConvertTo-Json

Write-Host "Creating product with:"
Write-Host "Name: Kindora White T-Shirt"
Write-Host "Price: 49.99"
Write-Host "Image URL: $($imageUrl.Substring(0, 50))..."

$response = Invoke-WebRequest `
  -Uri "http://localhost:5000/api/merchandise" `
  -Method POST `
  -Headers @{
    'Authorization' = "Bearer $token"
    'Content-Type' = 'application/json'
  } `
  -Body $body `
  -ErrorAction SilentlyContinue

Write-Host "Status Code: $($response.StatusCode)"
$responseData = $response.Content | ConvertFrom-Json
$responseData.data | Format-List

# Save product ID for reference
$productId = $responseData.data.id
Write-Host "Product created with ID: $productId"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-here",
    "name": "Kindora White T-Shirt",
    "price": 49.99,
    "image_url": "https://xxxx.supabase.co/storage/v1/object/public/Kindora/products/...",
    "category": "apparel",
    "stock_quantity": 20
  }
}
```

### Step 4.2: Verify in Supabase
1. Go to **Supabase Dashboard**
2. Click **Table Editor** (left sidebar)
3. Select **merchandise** table
4. You should see your product with:
   - ✅ `name` = "Kindora White T-Shirt"
   - ✅ `price` = 49.99
   - ✅ `image_url` = Full URL (NOT null, NOT empty)

---

## PHASE 5: Test in Admin Panel (5 minutes)

### Step 5.1: Open Admin Panel

In PowerShell (NEW terminal window):

```powershell
cd "c:\Users\Asus\Desktop\Kindora-\admin_panel"
npm start
```

✅ Wait for browser to open: http://localhost:3000

### Step 5.2: Upload Image via UI

1. Navigate to **Merchandise** section (left menu)
2. Click **Add Product** button
3. Fill in the form:
   - Name: "Test Upload"
   - Price: 29.99
   - Stock: 15
   - Category: "apparel"
4. Click file upload button
5. Select an image from your computer
6. Click **Save** button

### Step 5.3: Check Result

**In browser:**
- Does product appear in list?
- Does image show (NOT placeholder)?
- Can you see the real photo?

**In Supabase:**
1. Go to merchandise table
2. Look at the last created row
3. Check `image_url` field
4. Is it populated with a real URL?

---

## 🔍 DEBUGGING - If Image Still Doesn't Show

### Debug Check 1: Is Upload Working?

Run this in PowerShell:

```powershell
# Check if storage endpoint exists
$response = Invoke-WebRequest `
  -Uri "http://localhost:5000/api" `
  -Method GET

$response.Content | ConvertFrom-Json | Format-List
```

✅ Should show `storage: /api/storage` in endpoints list.

### Debug Check 2: Is File Actually Uploading?

Open **DevTools** in admin panel (F12) → **Network** tab:

1. Try to upload an image
2. Look for a request to `/api/storage/upload`
3. Check the **Response** tab
4. Should show:
```json
{
  "success": true,
  "url": "https://..."
}
```

**❌ If response shows error:**
- Check the error message
- See Phase 6 below

### Debug Check 3: Is Database Storing URL?

In Supabase SQL Editor, run:

```sql
SELECT id, name, image_url, created_at 
FROM merchandise 
ORDER BY created_at DESC 
LIMIT 5;
```

**❌ If `image_url` is NULL:**
- URL is not being saved to database
- Check merchandise controller

**✅ If `image_url` has URL:**
- Copy the URL
- Paste it in browser
- If image loads, frontend issue
- If image doesn't load, Supabase storage issue

### Debug Check 4: Frontend Issue

In admin panel, **inspect image element**:

1. Press F12 → **Elements** tab
2. Find `<img>` tag for product
3. Check `src` attribute
4. Should match `image_url` from database

**❌ If `src` shows placeholder URL:**
- Check merchandise display component
- Verify it's using `product.image_url`

---

## 🆘 PHASE 6: Troubleshooting

### Problem: "File type not allowed"

**Solution:**
Make sure you're uploading: `jpg, png, gif, webp, mp4, mov`

### Problem: "SUPABASE_SERVICE_ROLE_KEY is not configured"

**Solution:**
1. Go to Supabase project settings
2. Find your Service Role Key
3. Add to `.env` in backend folder:
   ```
   SUPABASE_SERVICE_ROLE_KEY=your_key_here
   ```
4. Restart backend server

### Problem: "Supabase configuration missing"

**Solution:**
Check your `.env` file has:
```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
SUPABASE_STORAGE_BUCKET=Kindora
```

### Problem: "401 Unauthorized"

**Solution:**
1. Get a new token (Step 3.1)
2. Make sure token is not expired
3. Token should start with "eyJ"

### Problem: Imageurl is NULL in database

**Solution:**
1. Check upload response has `url` field
2. Check create product request sends `image_url`
3. Verify merchandise controller creates record with URL

---

## ✅ Success Checklist

- [ ] Backend server running on port 5000
- [ ] Supabase tables created
- [ ] Image uploads successfully (Step 3.2)
- [ ] Got valid image URL from upload
- [ ] Product created with image URL (Step 4.1)
- [ ] Product URL stored in database (Step 4.2)
- [ ] Admin panel shows real image (Step 5.3)
- [ ] NOT showing placeholder anymore! 🎉

---

## 🚨 If Still Not Working

Run this diagnostic:

```powershell
# Check all configs
Write-Host "=== BACKEND CHECKS ===" 
Write-Host "Backend running? Try: curl http://localhost:5000/api"

Write-Host "`n=== STORAGE ENDPOINT ===" 
$api = Invoke-WebRequest http://localhost:5000/api | ConvertFrom-Json
$api.endpoints

Write-Host "`n=== DATABASE ===" 
Write-Host "Check Supabase merchandise table has your products"

Write-Host "`n=== IMAGE STORAGE ===" 
Write-Host "Check Supabase Storage bucket 'Kindora' has files"
```

---

Follow these steps **exactly in order** and your images will work! 🚀

