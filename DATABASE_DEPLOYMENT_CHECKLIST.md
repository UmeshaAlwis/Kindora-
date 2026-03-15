# Database Deployment Checklist

Complete this checklist to ensure proper Supabase setup for Kindora.

## Pre-Deployment Verification

- [ ] Supabase project created and API keys available
- [ ] Project URL: `https://[project-id].supabase.co`
- [ ] Backend `.env` file exists with placeholder values
- [ ] Git repository initialized with `.env` in `.gitignore`

## Schema Deployment

### Execute Main Schema

- [ ] Open Supabase Dashboard → SQL Editor
- [ ] Create new query
- [ ] Copy & paste `backend/database/schema.sql` 
- [ ] Execute query - should succeed with no errors
- [ ] Verify 6 tables created:
  - [ ] `campaigns`
  - [ ] `charities`
  - [ ] `donations`
  - [ ] `wallets`
  - [ ] `wallet_transactions`
  - [ ] `messages`

### Verify Triggers & Indexes

- [ ] Open SQL Editor → New Query
- [ ] Run: `SELECT * FROM information_schema.triggers WHERE trigger_schema = 'public';`
  - Expected: At least 6 triggers (update_at triggers + business logic)
- [ ] Run: `SELECT * FROM pg_indexes WHERE schemaname = 'public';`
  - Expected: Multiple indexes on foreign keys and frequently queried fields

## RLS Policies Deployment

- [ ] Open SQL Editor → New Query
- [ ] Copy & paste `backend/database/policies.sql`
- [ ] Execute query - should succeed with no errors
- [ ] Verify policies created:
  - [ ] RLS enabled on all 6 tables
  - [ ] Campaign policies: view_all, create, update_own, delete_own
  - [ ] Wallet policies: view_own, update_own
  - [ ] Transaction policies: view_own
  - [ ] Message policies: view_sent, view_received, create, update_received

## Backend Configuration

- [ ] Update `backend/.env` with actual Supabase credentials:
  ```
  SUPABASE_URL=https://[project-id].supabase.co
  SUPABASE_ANON_KEY=[your-anon-key]
  SUPABASE_SERVICE_KEY=[your-service-key]
  SUPABASE_JWT_SECRET=[your-jwt-secret]
  ```
- [ ] Restart backend server: `npm run dev`
- [ ] Check backend logs for "Supabase connected" message

## Database Testing

### Manual Query Tests

- [ ] Test 1: Query campaigns
  - [ ] Run: `SELECT * FROM campaigns LIMIT 1;`
  - [ ] Result: Should return empty (no test data yet)

- [ ] Test 2: Test wallet creation trigger
  - [ ] Run: 
    ```sql
    INSERT INTO auth.users (id, email, user_metadata) 
    VALUES (gen_random_uuid(), 'test@example.com', '{}');
    ```
  - [ ] Verify wallet auto-created: 
    ```sql
    SELECT * FROM wallets WHERE user_id = [just-inserted-user-id];
    ```

- [ ] Test 3: Test RLS policies
  - [ ] Create two test users
  - [ ] User 1 signs in, creates campaign
  - [ ] User 2 signs in, verifies cannot view User 1's profile/wallet via backend

### Backend API Tests

- [ ] Run: `npm run test:schema`
  - [ ] All tests pass
  - [ ] No database connection errors
  - [ ] Wallet functions accessible

- [ ] Run: `npm run test` (full test suite)
  - [ ] Auth tests pass
  - [ ] Campaign tests pass
  - [ ] Wallet tests pass
  - [ ] Payment tests pass

## Flutter Integration Testing

### Setup

- [ ] Flutter app configured with Firebase Auth
- [ ] Firebase credentials added to `flutter_app/firebase.json`
- [ ] Backend API endpoints configured in Flutter

### Wallet Feature Tests

- [ ] Test: Dashboard loads
  - [ ] Run Flutter app
  - [ ] Navigate to Dashboard (Home tab)
  - [ ] "Top up" button → WalletTopUpPage loads
  - [ ] "History" button → Empty transaction history (new user)
  - [ ] Verify no errors in console

- [ ] Test: Wallet top-up (Stripe test mode)
  - [ ] Click "Top up" on Dashboard
  - [ ] Select quick amount (500 LKR)
  - [ ] Process payment with Stripe test card: `4242 4242 4242 4242`
  - [ ] Verify payment succeeds
  - [ ] Check: Dashboard balance updates
  - [ ] Check: Transaction appears in history

- [ ] Test: Campaign donation with wallet
  - [ ] Navigate to Campaigns
  - [ ] Open a campaign and click "Support Campaign"
  - [ ] On Payment page, select "Wallet" payment method
  - [ ] Enter donation amount (verify balance sufficient)
  - [ ] Process payment
  - [ ] Verify: Wallet balance decreases
  - [ ] Verify: Transaction appears in history with "donation" type
  - [ ] Verify: Campaign raised_amount increases

- [ ] Test: Multiple transactions
  - [ ] Perform 5+ wallet transactions (top-ups and donations)
  - [ ] Verify transaction history shows all in correct order
  - [ ] Verify balance calculations are accurate
  - [ ] Check timestamps are correct

## Error Handling Tests

- [ ] Test: Insufficient wallet balance
  - [ ] Try to donate more than wallet balance
  - [ ] Verify: Error message shown
  - [ ] Verify: Payment not processed
  - [ ] Verify: Balance unchanged

- [ ] Test: Network error handling
  - [ ] Disconnect backend service temporarily
  - [ ] Try to fetch wallet balance/history
  - [ ] Verify: Loading state shown
  - [ ] Verify: Error message displayed
  - [ ] Reconnect backend → data loads after retry

- [ ] Test: RLS policy enforcement
  - [ ] As User 1, try to query User 2's wallet via direct API
  - [ ] Verify: 403 Forbidden or empty result (RLS enforces)
  - [ ] As User 1, try to update User 2's wallet
  - [ ] Verify: 403 Forbidden

## Production Checklist

- [ ] Backup Supabase database (automated daily backups enabled)
- [ ] Enable Supabase row-level security monitoring
- [ ] Set up error logging/alerting
- [ ] Test database performance with load testing
- [ ] Document database backup & recovery procedures
- [ ] Update Git with all schema files committed
- [ ] Tag release version with database schema version

## Rollback Plan

If issues occur after deployment:

1. **Backup current state**: 
   ```bash
   # Export current database state
   pg_dump -U postgres -d kindora > backup.sql
   ```

2. **Rollback to previous schema**:
   - Delete corrupted tables (if any)
   - Re-run `schema.sql` from fresh
   - Re-run `policies.sql`

3. **Verify rollback**:
   - Run test suite: `npm run test:schema`
   - Test Flutter app features

## Post-Deployment

- [ ] Send setup confirmation to team
- [ ] Update project documentation with database stats
- [ ] Monitor backend logs for 24 hours
- [ ] Schedule first database maintenance review
- [ ] Create recurring backup verification process

## Notes

- Database schema includes automatic `created_at` and `updated_at` timestamps
- All sensitive operations (wallet top-up, donations) are logged in `wallet_transactions`
- RLS policies ensure multi-tenant security
- Consider setting up database alerts for:
  - Large spikes in transactions
  - Failed donation attempts
  - Unusual wallet activity

---

**Last Updated**: After wallet feature implementation
**Status**: Ready for deployment
**Next Steps**: Execute schema.sql in Supabase SQL Editor
