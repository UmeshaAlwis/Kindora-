# Kindora Supabase Database Deployment Guide

Complete step-by-step process to deploy all tables, triggers, and RLS policies to Supabase.

---

## Step 1: Access Supabase Dashboard

1. Open your browser and go to: **https://app.supabase.com**
2. Sign in with your Supabase credentials
3. Select your **Kindora project** from the project list
4. You'll see the main dashboard

---

## Step 2: Navigate to SQL Editor

1. In the left sidebar, click **"SQL Editor"** (query icon)
2. You should see a list of past queries or a blank editor
3. Click **"New Query"** button (top right, or center of screen)

---

## Step 3: Deploy Main Database Schema

### 3.1: Copy the Schema File Content

1. Open this file on your computer: **`backend/database/schema.sql`**
2. Select all content: `Ctrl+A`
3. Copy it: `Ctrl+C`

### 3.2: Paste into Supabase SQL Editor

1. Go back to the Supabase SQL Editor (the "New Query" tab you created)
2. Click in the editor area (where SQL code goes)
3. Paste the content: `Ctrl+V`
4. You should see the SQL code for creating tables, triggers, and indexes

### 3.3: Execute the Schema

1. Click the **"Run"** button (blue play icon, top right of editor)
   - OR use keyboard shortcut: `Ctrl+Enter` (Windows) or `Cmd+Enter` (Mac)
2. Wait for the execution to complete (usually 5-30 seconds)
3. You should see a green notification: **"Query executed successfully"**

✅ **If successful**, you'll see messages like:
```
CREATE TABLE
CREATE INDEX
CREATE FUNCTION
...
```

❌ **If failed**, you'll see an error message. Common issues:
- Missing Supabase credentials: Check `.env` file
- Syntax error: Verify schema.sql is correct
- See **Troubleshooting** section below

---

## Step 4: Deploy RLS Policies

### 4.1: Copy the Policies File Content

1. Open this file: **`backend/database/policies.sql`**
2. Select all content: `Ctrl+A`
3. Copy it: `Ctrl+C`

### 4.2: Create New Query in Supabase

1. In Supabase SQL Editor, click **"New Query"** button again
2. A new tab will appear with an empty editor
3. Click in the editor and paste: `Ctrl+V`
4. You should see the RLS policies code

### 4.3: Execute the Policies

1. Click **"Run"** button (blue play icon)
2. Wait for completion
3. You should see: **"Query executed successfully"**

✅ **If successful**, you'll see multiple policy creation messages:
```
ALTER TABLE ... ENABLE ROW LEVEL SECURITY
CREATE POLICY ...
GRANT ...
```

---

## Step 5: Verify All Tables Were Created

### 5.1: List All Tables

1. Create a new query in SQL Editor
2. Copy and paste this verification query:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
```

3. Click Run
4. You should see **7 tables** listed:
   - `campaigns`
   - `charities`
   - `donations`
   - `messages`
   - `users` ← **NEW**
   - `wallet_transactions`
   - `wallets`

### 5.2: Verify Triggers Created

1. Create a new query
2. Copy and paste:

```sql
SELECT event_object_table, trigger_name 
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY event_object_table;
```

3. Click Run
4. You should see **at least 5 triggers** like:
   - `trigger_update_users_updated_at` (NEW)
   - `trigger_update_campaigns_updated_at`
   - etc.

### 5.3: Verify RLS Policies

1. Create a new query
2. Copy and paste:

```sql
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename;
```

3. Click Run
4. You should see multiple policies per table (example):
   - `campaigns` → campaigns_create, campaigns_delete_own, etc.
   - `users` → users_view_own, users_update_own, etc.
   - `wallets` → wallets_view_own, wallets_update_own, etc.

### 5.4: Verify Indexes Created

1. Create a new query
2. Copy and paste:

```sql
SELECT tablename, indexname 
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename;
```

3. Click Run
4. You should see indexes on foreign keys and frequently used columns

---

## Step 6: Test User Creation (Optional but Recommended)

This verifies that the trigger for auto-wallet creation works.

### 6.1: Manually Create a Test User

1. Create a new query
2. Copy and paste:

```sql
INSERT INTO users (
  email, 
  full_name, 
  phone_number, 
  role, 
  firebase_uid, 
  is_active
) VALUES (
  'test@example.com',
  'Test User',
  '0701234567',
  'donor',
  'firebase-uid-12345',
  true
)
RETURNING id, email, full_name;
```

3. Click Run
4. You should see the created user with their UUID printed

**Note the `id` (UUID) from the result** - you'll need it for the next step.

### 6.2: Verify Wallet Was Auto-Created

1. Create a new query
2. Copy and paste (replace `[USER_ID]` with the UUID from step 6.1):

```sql
SELECT wallet_id, user_id, balance, total_recharged, total_spent 
FROM wallets 
WHERE user_id = '[USER_ID]';
```

3. Click Run
4. You should see **1 wallet** created with:
   - `balance = 0.00`
   - `total_recharged = 0.00`
   - `total_spent = 0.00`

✅ **If wallet exists**, the trigger is working!

### 6.3: Clean Up Test Data (Optional)

If you want to remove the test user and wallet:

```sql
-- Delete will cascade to wallets due to foreign key
DELETE FROM users WHERE email = 'test@example.com';
```

---

## Step 7: Test RLS Policies (Optional but Recommended)

Verify that users can only see their own data.

### 7.1: Create Test Users

```sql
-- User 1
INSERT INTO users (
  email, full_name, role, firebase_uid
) VALUES (
  'user1@test.com', 'User One', 'donor', 'uid-user1'
)
RETURNING id;

-- User 2
INSERT INTO users (
  email, full_name, role, firebase_uid
) VALUES (
  'user2@test.com', 'User Two', 'donor', 'uid-user2'
)
RETURNING id;
```

Copy the two returned UUIDs.

### 7.2: Test RLS in Backend

See **FIREBASE_SUPABASE_SYNC.md** section "Verify Sync" for backend testing.

---

## Step 8: Check Database Statistics (Optional)

View created tables and their sizes:

```sql
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Troubleshooting

### Issue: "Query executed successfully" but nothing happened

**Cause**: Schema was already deployed or queries were empty

**Solution**:
1. Verify tables exist (Step 5.1)
2. If they exist, deployment is complete ✅
3. If they don't exist, check the error message in the Supabase logs

### Issue: Error "Relation already exists"

**Cause**: Tables were already created in a previous deployment

**Solution**:
- This is OK! The schema uses `CREATE TABLE IF NOT EXISTS`
- You can safely re-run the schema without issues
- Or, skip to Step 5 to verify existing tables

### Issue: "Permission denied" error

**Cause**: Using wrong API key (anon instead of service role)

**Solution**:
1. Go to Supabase Dashboard → Settings → API
2. Make sure you're logged in as project owner
3. Copy `service_role` key (not `anon` key)
4. Update `.env` file: `SUPABASE_SERVICE_ROLE_KEY=...`
5. Restart backend: `npm run dev`

### Issue: "Syntax error in SQL"

**Cause**: Schema file got corrupted or truncated during copy/paste

**Solution**:
1. Re-open `backend/database/schema.sql` in VS Code
2. Verify file is complete (should be ~300+ lines)
3. Copy again and paste into Supabase

### Issue: Foreign key error on wallets table

**Cause**: `users` table doesn't exist yet

**Solution**:
1. Verify Step 3 completed successfully (execute schema.sql first)
2. Don't execute policies.sql before schema.sql
3. Restart and follow steps in order: Schema → Policies → Verify

### Issue: Wallet not auto-created for new user in registration

**Cause**: Trigger didn't execute during user creation

**Solution**:
1. Check if trigger `trigger_update_users_updated_at` exists (Step 5.2)
2. Verify wallets table has `wallet_id` as PRIMARY KEY
3. Check backend logs for error messages when registering
4. Manually create wallet via:
   ```sql
   INSERT INTO wallets (user_id, balance) 
   VALUES ('[user-uuid]', 0);
   ```

### Issue: Backend can't connect to Supabase

**Cause**: `.env` file has wrong credentials

**Solution**:
1. Open `.env` file
2. Verify these variables are set:
   ```
   SUPABASE_URL=https://[project-id].supabase.co
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
   ```
3. Get correct values from Supabase Dashboard → Settings → API
4. Restart backend: `npm run dev`

---

## Deployment Checklist

Use this checklist to verify complete deployment:

- [ ] **Step 1**: Accessed Supabase Dashboard
- [ ] **Step 2**: Navigated to SQL Editor
- [ ] **Step 3**: Executed schema.sql successfully
  - [ ] 3.1: Copied schema file
  - [ ] 3.2: Pasted into SQL Editor
  - [ ] 3.3: Ran query, got "Query executed successfully"
- [ ] **Step 4**: Executed policies.sql successfully
  - [ ] 4.1: Copied policies file
  - [ ] 4.2: Created new query in SQL Editor
  - [ ] 4.3: Ran query, got "Query executed successfully"
- [ ] **Step 5**: Verified all components
  - [ ] 5.1: Listed 7 tables (users, campaigns, charities, donations, wallets, wallet_transactions, messages)
  - [ ] 5.2: Found at least 5 triggers
  - [ ] 5.3: Found RLS policies on each table
  - [ ] 5.4: Found indexes on foreign keys
- [ ] **Step 6**: (Optional) Tested user creation and wallet auto-creation
  - [ ] 6.1: Created test user
  - [ ] 6.2: Verified wallet auto-created
- [ ] **Step 7**: (Optional) Tested RLS policies
  - [ ] 7.1: Created test users
  - [ ] 7.2: Verified users can't see each other's data
- [ ] **Step 8**: (Optional) Checked database statistics

---

## What Each File Does

### `backend/database/schema.sql`
- ✅ Creates 7 tables (users, campaigns, charities, donations, wallets, wallet_transactions, messages)
- ✅ Creates 5 triggers (auto-update timestamps, auto-update wallet balances)
- ✅ Creates 17 indexes (for fast queries)
- ✅ Sets up foreign keys with CASCADE delete
- ✅ Creates CHECK constraints for data validation

### `backend/database/policies.sql`
- ✅ Enables RLS on all 7 tables
- ✅ Creates RLS policies for data access control
- ✅ Ensures users can only access their own data
- ✅ Creates grants for authenticated and anonymous users
- ✅ Sets up auto-wallet creation trigger on signup

---

## What's Now Enabled

After deployment:

✅ **User Registration**
- Firebase creates auth user
- Backend syncs to Supabase `users` table
- Wallet auto-created with 0 balance
- RLS prevents users from seeing each other's data

✅ **Campaigns & Donations**
- Users can create campaigns
- Users can donate to campaigns
- Donation amounts auto-summed in `raised_amount`
- Queries are fast with indexes

✅ **Wallet System**
- Users can top-up wallet via Stripe
- Users can donate from wallet
- Transactions tracked in `wallet_transactions`
- Balance updates automatically

✅ **Messages**
- Users can send/receive messages
- RLS ensures users only see their own messages
- Paginated loading with indexes

---

## Next Steps After Deployment

1. **Test Backend**: Run `npm run test:schema` to verify backend can connect
2. **Test Registration**: Register a new user in Flutter app to verify entire flow
3. **Monitor Logs**: Check backend logs for any Supabase connection errors
4. **Load Balancing**: Consider enabling Supabase read replicas for scaling

---

## Support

If stuck:
1. Check **Troubleshooting** section above
2. Review **FIREBASE_SUPABASE_SYNC.md** for integration details
3. Check Supabase Dashboard → Logs for database errors
4. Run Step 5 verification queries to diagnose issues

**Estimated Time**: 10-15 minutes for complete deployment
**Success Indicator**: All verification queries in Step 5 return expected results

