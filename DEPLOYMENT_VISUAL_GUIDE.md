# Supabase Deployment - Visual Walkthrough

## Complete Step-by-Step with Screenshots & Descriptions

---

## PHASE 1: Login to Supabase

### Step 1.1: Open Supabase
- **What to do**: Open your web browser (Chrome, Firefox, Edge, Safari)
- **URL**: Go to `https://app.supabase.com`
- **What you see**: Supabase login page (email + password fields)

### Step 1.2: Enter Credentials
- **Email**: Enter your Supabase account email
- **Password**: Enter your Supabase password
- **Click**: "Sign in" button

### Step 1.3: Select Project
- **What you see**: Dashboard with list of projects
- **Find**: "Kindora" project (your project name)
- **Click**: On the Kindora project card
- **What you see**: Project dashboard with sidebar on left

---

## PHASE 2: Access SQL Editor

### Step 2.1: Open SQL Editor
**Location on Dashboard:**
- Left sidebar (vertical menu on screen left)
- Look for icon that looks like: `<>` or scroll down to find "SQL Editor"
- **Click**: "SQL Editor" option
- **What you see**: SQL Editor interface with list of past queries

### Step 2.2: Create New Query
**How to:**
- Look for **"New Query"** button (top right corner, or center of screen if empty)
- **Click**: "New Query" button
- **What you see**: Blank SQL editor area with cursor blinking
- **Window title**: "Untitled" or "SQL_1"

---

## PHASE 3: Deploy Schema (Part 1)

### Step 3.1: Locate Schema File
**On Your Computer:**
- Open File Explorer
- Navigate to: `C:\Users\asus\OneDrive\Desktop\Kindora-\backend\database\`
- Find file: `schema.sql`
- **Right-click** → "Open with" → "Visual Studio Code" (or your text editor)

### Step 3.2: Copy All Schema Content
**In VS Code:**
- All the SQL code should be visible
- **Select All**: Press `Ctrl+A` (or Cmd+A on Mac)
- Everything turns blue/highlighted (selected)
- **Copy**: Press `Ctrl+C` (or Cmd+C)
- Code is now in your clipboard

### Step 3.3: Paste into Supabase
**Back in Supabase SQL Editor:**
- Click in the editor area (the white box where you see cursor)
- **Paste**: Press `Ctrl+V` (or Cmd+V)
- **What you see**: Hundreds of lines of SQL code appear in the editor

**Example of what you should see:**
```
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  ...
)

CREATE TABLE IF NOT EXISTS campaigns (
  ...
```

### Step 3.4: Execute Schema Query
**Execute Query:**
- Look at **top right corner** of editor
- Find blue button with play icon ▶ or labeled "**Run**"
- **Click**: The Run button
- **Wait**: 5-30 seconds while query executes

**What happens:**
- You see spinning animation (loading)
- Query processes on Supabase servers

**Success Message:**
- Green notification appears: `✓ Query executed successfully`
- Below the editor, you see multiple output lines like:
  ```
  CREATE TABLE
  CREATE INDEX
  CREATE FUNCTION
  CREATE TRIGGER
  ...
  ```

### Step 3.5: Verify Success
- If you see `✓ Query executed successfully`, move to Step 4 ✅
- If you see red error message:
  - Take note of error text
  - Check **Troubleshooting** section in SUPABASE_DEPLOYMENT_STEPS.md
  - Common fix: `.env` credentials might need updating

---

## PHASE 4: Deploy Policies (Part 2)

### Step 4.1: Create New Query #2
**In Supabase SQL Editor:**
- Click **"New Query"** button again (top right)
- New tab appears (might show "SQL_2" or "Untitled_1")
- Have blank editor ready
- **What you see**: Clean white editor box, cursor blinking

### Step 4.2: Copy Policies File Content
**On Your Computer:**
- Open File Explorer
- Navigate to: `C:\Users\asus\OneDrive\Desktop\Kindora-\backend\database\`
- Find file: `policies.sql`
- Right-click → "Open with" → "VS Code" (or editor)

**In VS Code:**
- Select all: `Ctrl+A`
- Copy: `Ctrl+C`

### Step 4.3: Paste into New Query
**Back in Supabase:**
- Click in the blank editor (Query #2)
- Paste: `Ctrl+V`
- You should see policies code:
  ```
  ALTER TABLE users ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "users_view_own" ON users...
  ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "campaigns_create" ON campaigns...
  ...
  ```

### Step 4.4: Execute Policies Query
- Click **Run** button (blue play icon, top right)
- Wait for execution (5-30 seconds)

**Success Message:**
- Green notification: `✓ Query executed successfully`
- Output shows multiple lines like:
  ```
  ALTER TABLE
  CREATE POLICY
  GRANT USAGE ON SCHEMA
  ...
  ```

---

## PHASE 5: Verify Everything Works

### Step 5.1: Check All Tables Exist
**Create Verification Query:**
- Click **"New Query"** again
- Paste this code:
  ```sql
  SELECT table_name 
  FROM information_schema.tables 
  WHERE table_schema = 'public'
  ORDER BY table_name;
  ```

- Click **Run**
- **Expected Result** - You should see 7 tables listed:
  ```
  campaigns
  charities
  donations
  messages
  users
  wallet_transactions
  wallets
  ```

✅ **If you see all 7 tables, schema deployment successful!**

### Step 5.2: Check Triggers Exist
**Create Verification Query:**
- Click **"New Query"**
- Paste this code:
  ```sql
  SELECT event_object_table, trigger_name 
  FROM information_schema.triggers 
  WHERE trigger_schema = 'public'
  ORDER BY event_object_table;
  ```

- Click **Run**
- **Expected Result** - You should see triggers for:
  - `update_users_updated_at`
  - `update_campaigns_updated_at`
  - `update_wallets_updated_at`
  - etc.

✅ **If you see triggers listed, triggers deployment successful!**

### Step 5.3: Check RLS Policies
**Create Verification Query:**
- Click **"New Query"**
- Paste this code:
  ```sql
  SELECT tablename, COUNT(*) as policy_count 
  FROM pg_policies 
  WHERE schemaname = 'public'
  GROUP BY tablename
  ORDER BY tablename;
  ```

- Click **Run**
- **Expected Result** - You should see each table with policy counts:
  ```
  campaigns        | 4
  charities        | 1
  donations        | 2
  messages         | 4
  users            | 3
  wallet_transactions | 1
  wallets          | 2
  ```

✅ **If all tables have policies, RLS deployment successful!**

---

## PHASE 6: Test User Creation (Optional)

### Step 6.1: Create Test User
- Click **"New Query"**
- Paste this code:
  ```sql
  INSERT INTO users (
    email, 
    full_name, 
    role, 
    firebase_uid
  ) VALUES (
    'test@example.com',
    'Test User',
    'donor',
    'test-firebase-uid-123'
  )
  RETURNING id, email, full_name, firebase_uid;
  ```

- Click **Run**
- **Expected Result** - You see the created user with UUID:
  ```
  id                                    | email              | full_name  | firebase_uid
  12345678-1234-1234-1234-123456789012 | test@example.com   | Test User  | test-firebase-uid-123
  ```

**Copy the UUID (the long ID) for the next step**

### Step 6.2: Verify Wallet Auto-Created
- Click **"New Query"**
- Replace `[USER_UUID]` with the UUID you just copied
- Paste this code:
  ```sql
  SELECT wallet_id, user_id, balance 
  FROM wallets 
  WHERE user_id = '[USER_UUID]';
  ```

- Click **Run**
- **Expected Result** - You see 1 wallet row:
  ```
  wallet_id                             | user_id                              | balance
  87654321-4321-4321-4321-210987654321  | 12345678-1234-1234-1234-123456789012 | 0.00
  ```

✅ **If wallet exists, auto-creation trigger works!**

### Step 6.3: Clean Up (Optional)
If you want to remove test user:
- Click **"New Query"**
- Paste:
  ```sql
  DELETE FROM users WHERE email = 'test@example.com';
  ```
- Click **Run**
- Test data is deleted

---

## PHASE 7: Configuration Check

### Step 7.1: Verify Backend `.env` File
**On Your Computer:**
- Open file: `C:\Users\asus\OneDrive\Desktop\Kindora-\backend\.env`
- Verify these lines exist:
  ```
  SUPABASE_URL=https://ucxqakixdpqqmbbpeptm.supabase.co
  SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
  ```

✅ **If present, backend is already configured!**

---

## PHASE 8: Final Testing (Connect Backend)

### Step 8.1: Start Backend Server
**Open Terminal:**
- Open PowerShell or Command Prompt
- Navigate to backend folder:
  ```
  cd C:\Users\asus\OneDrive\Desktop\Kindora-\backend
  ```

**Start server:**
```
npm run dev
```

**What you see:**
- Lines of output appear
- Should see: `Server running on port 5001`
- Look for: `[SupabaseUserService]` or `[Supabase]` messages (indicating connection)

✅ **If server starts without errors, backend is connected!**

### Step 8.2: Test Registration
**In Postman or Browser:**

**URL**: `http://localhost:5001/api/auth/register`

**Method**: POST

**Body (JSON)**:
```json
{
  "email": "newuser@test.com",
  "password": "Password123!",
  "full_name": "New User",
  "role": "donor",
  "phone_number": "0701234567"
}
```

**Send Request**

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "user": {
      "user_id": "12345678-...",
      "email": "newuser@test.com",
      "full_name": "New User",
      "role": "donor"
    }
  },
  "message": "User registered successfully"
}
```

### Step 8.3: Verify in Supabase
**Check Supabase Dashboard:**
- Go back to Supabase SQL Editor
- Create new query:
  ```sql
  SELECT email, full_name, role FROM users 
  WHERE email = 'newuser@test.com';
  ```
- Click **Run**
- **Expected**: User appears in results ✅

---

## Success Checklist

- [ ] ✅ Logged into Supabase
- [ ] ✅ Created Query 1 with schema.sql
- [ ] ✅ Executed Query 1 (saw "Query executed successfully")
- [ ] ✅ Created Query 2 with policies.sql
- [ ] ✅ Executed Query 2 (saw "Query executed successfully")
- [ ] ✅ Verified 7 tables exist
- [ ] ✅ Verified triggers exist
- [ ] ✅ Verified RLS policies exist
- [ ] ✅ (Optional) Created test user
- [ ] ✅ (Optional) Verified wallet auto-created
- [ ] ✅ Backend `.env` is configured
- [ ] ✅ Backend server starts with `npm run dev`
- [ ] ✅ Registration creates user in Supabase

**If all checked: DEPLOYMENT COMPLETE! 🎉**

---

## Estimated Time

| Phase | Time |
|-------|------|
| Phase 1 (Login) | 1 min |
| Phase 2 (Access Editor) | 1 min |
| Phase 3 (Deploy Schema) | 5 min |
| Phase 4 (Deploy Policies) | 3 min |
| Phase 5 (Verify) | 3 min |
| Phase 6 (Test User) | 2 min |
| Phase 7 (Config Check) | 1 min |
| Phase 8 (Backend Test) | 2 min |
| **Total** | **~20 minutes** |

---

## Troubleshooting Quick Links

- **"Query executed successfully" but tables don't show**: Phase 5.1
- **Permission denied**: Check `.env` has `SUPABASE_SERVICE_ROLE_KEY`
- **Schema fails to run**: Verify file is not corrupted
- **Wallet not created**: Check Phase 6.2 - trigger exists?
- **Backend can't connect**: Restart with `npm run dev`

For detailed troubleshooting, see: **SUPABASE_DEPLOYMENT_STEPS.md**

