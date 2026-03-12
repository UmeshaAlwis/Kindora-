# Supabase Database Setup Guide

This guide walks through deploying the Kindora database schema to Supabase.

## Prerequisites

1. Supabase project created and initialized
2. Project URL and API keys available
3. Access to Supabase Dashboard

## Step-by-Step Setup

### Step 1: Execute Main Schema

1. **Open Supabase Dashboard**
   - Go to [app.supabase.com](https://app.supabase.com)
   - Select your Kindora project

2. **Navigate to SQL Editor**
   - Click "SQL Editor" in sidebar
   - Click "New Query"

3. **Execute schema.sql**
   - Copy the entire contents of `backend/database/schema.sql`
   - Paste into the SQL editor
   - Click "Run" or press `Cmd+Enter` (Mac) / `Ctrl+Enter` (Windows)
   - Wait for "Query executed successfully" message

4. **Verify Tables Created**
   - In SQL Editor, run:
     ```sql
     SELECT table_name FROM information_schema.tables 
     WHERE table_schema = 'public';
     ```
   - Should see: campaigns, charities, donations, wallets, wallet_transactions, messages

### Step 2: Create RLS Policies

1. **Execute policies.sql**
   - Go back to SQL Editor
   - Click "New Query"
   - Copy entire contents of `backend/database/policies.sql`
   - Paste into editor
   - Click "Run"
   - Wait for confirmation

2. **Verify Policies Created**
   - In SQL Editor, run:
     ```sql
     SELECT tablename, policyname FROM pg_policies;
     ```
   - Should see policies for all tables

### Step 3: Verify Triggers and Indexes

In SQL Editor, verify all database objects are created:

```sql
-- Check functions
SELECT p.proname FROM pg_proc p 
JOIN pg_namespace n ON p.pronamespace = n.oid 
WHERE n.nspname = 'public';

-- Check triggers
SELECT trigger_name, event_object_table FROM information_schema.triggers 
WHERE trigger_schema = 'public';

-- Check indexes
SELECT tablename, indexname FROM pg_indexes 
WHERE schemaname = 'public';
```

### Step 4: Enable Realtime (Optional)

For live updates in the Flutter app:

1. Go to "Database" → "Realtime" section
2. Toggle "Realtime" on for relevant tables:
   - `donations` (for campaign amount updates)
   - `wallet_transactions` (for transaction history)
   - `messages` (for messaging features)

### Step 5: Set Up Backend Environment

Update `.env` file in backend with Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key
SUPABASE_JWT_SECRET=your_jwt_secret
```

### Step 6: Test Database Connection

Run backend tests:

```bash
cd backend
npm run test:schema
```

Expected output: All schema tests passing

### Step 7: Seed Initial Data (Optional)

To add test data, create `backend/database/seed.sql`:

```sql
-- Insert test charity
INSERT INTO charities (name, description, website, verified) VALUES 
('Care for Kids', 'Helping underprivileged children', 'https://careforkids.org', true);

-- Insert test campaigns
INSERT INTO campaigns (name, description, target_amount, category, user_id, charity_id) 
VALUES 
('School Supplies Drive', 'Provide educational materials', 50000, 'Education', 'user-id-here', 1);
```

Then execute in SQL Editor.

## Troubleshooting

### Issue: "relation 'campaigns' does not exist"

**Solution**: Schema wasn't executed properly. Rerun `schema.sql`:
```sql
-- Verify schema execution
SELECT EXISTS (
  SELECT 1 FROM information_schema.tables 
  WHERE table_name = 'campaigns'
);
```

If FALSE, rerun schema.sql from Step 1.

### Issue: RLS policies block all queries

**Causes & Solutions**:
- Auth not properly configured
- User UUID doesn't match expected format
- Check policy conditions:
  ```sql
  SELECT * FROM pg_policies WHERE tablename = 'wallets';
  ```

### Issue: Wallet features showing "404" errors

**Solution**: 
1. Verify `wallets` table exists: `SELECT COUNT(*) FROM wallets;`
2. Verify backend can connect to Supabase
3. Check backend logs: `npm run dev` for error details
4. Verify JWT token includes `sub` claim with user UUID

### Issue: Wallet balance not updating after donation

**Solution**: 
1. Verify trigger is active:
   ```sql
   SELECT * FROM information_schema.triggers 
   WHERE trigger_name = 'on_donation_created';
   ```
2. Check if record was inserted (check `wallet_transactions` table)
3. Verify wallet exists for user:
   ```sql
   SELECT * FROM wallets WHERE user_id = 'user-uuid';
   ```

## Database Structure Overview

### Campaigns Table
```
campaigns
├── campaign_id (UUID, Primary Key)
├── user_id (UUID, Foreign Key → auth.users)
├── charity_id (UUID, Foreign Key → charities)
├── name (Text)
├── description (Text)
├── target_amount (Numeric)
├── raised_amount (Numeric, AUTO)
├── category (Text)
├── status (active/completed/paused)
├── created_at (Timestamp, AUTO)
└── updated_at (Timestamp, AUTO)
```

### Wallets Table
```
wallets
├── wallet_id (UUID, Primary Key)
├── user_id (UUID, Foreign Key → auth.users, UNIQUE)
├── balance (Numeric, DEFAULT 0)
├── total_recharged (Numeric, DEFAULT 0)
├── total_spent (Numeric, DEFAULT 0)
├── created_at (Timestamp, AUTO)
└── updated_at (Timestamp, AUTO)
```

### Wallet Transactions Table
```
wallet_transactions
├── transaction_id (UUID, Primary Key)
├── wallet_id (UUID, Foreign Key → wallets)
├── type (credit/debit)
├── amount (Numeric)
├── description (Text)
├── reference_id (Text, Foreign Key reference)
├── created_at (Timestamp, AUTO)
└── metadata (JSONB, optional)
```

## Security Notes

- All tables have RLS enabled
- Users can only access their own data
- Wallets created automatically when user signs up
- Transactions are immutable (no update/delete policies)
- Financial data protected by RLS policies

## Next Steps

1. ✅ Execute schema.sql (this creates all tables, triggers, indexes)
2. ✅ Execute policies.sql (this secures the data with RLS)
3. ✅ Test backend connection to Supabase
4. ⏳ Run Flutter app and test wallet features
5. ⏳ Monitor logs for any database errors

## Testing Checklist

- [ ] Schema executes without errors
- [ ] All 6 tables created in Supabase
- [ ] RLS policies enabled on all tables
- [ ] Backend can query `wallets` table
- [ ] Test wallet top-up creates transaction
- [ ] Test donation updates wallet balance
- [ ] Test RLS prevents users from viewing others' wallets

## Support

For issues, check:
1. Supabase error logs: Dashboard → Logs
2. Backend server logs: `npm run dev`
3. Backend test suite: `npm run test:schema`
