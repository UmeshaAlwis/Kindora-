# Quick Deployment Reference

## 5-Minute Express Deployment

### **Step 1: Open Supabase**
```
https://app.supabase.com → Select Kindora project
```

### **Step 2: Create Query #1 (Schema)**
```
Left Sidebar: SQL Editor → New Query
Paste: Copy all from backend/database/schema.sql
Click: Run (Blue play button) ✓
```

### **Step 3: Create Query #2 (Policies)**
```
New Query
Paste: Copy all from backend/database/policies.sql
Click: Run ✓
```

### **Step 4: Verify**
Run these 2 verification queries:

**Verification Query 1 - Check Tables:**
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' ORDER BY table_name;
```
Expected: 7 tables (users, campaigns, charities, donations, wallets, wallet_transactions, messages)

**Verification Query 2 - Check Policies:**
```sql
SELECT COUNT(*) as policy_count FROM pg_policies 
WHERE schemaname = 'public';
```
Expected: 20+ policies

✅ **Done!** Database is deployed.

---

## Environment Variables (Already Configured)

Your `.env` already has:
```
SUPABASE_URL=https://ucxqakixdpqqmbbpeptm.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
```

These are used for backend to connect to Supabase.

---

## Testing After Deployment

### Test 1: Register a User
```bash
cd backend
npm run dev

# Then register in Flutter app or use Postman:
POST http://localhost:5001/api/auth/register
{
  "email": "newuser@test.com",
  "password": "password123",
  "full_name": "Test User",
  "role": "donor"
}
```

### Test 2: Verify User Synced to Supabase
```sql
-- In Supabase SQL Editor:
SELECT email, full_name, role FROM users 
WHERE email = 'newuser@test.com';
```

### Test 3: Verify Wallet Created
```sql
SELECT balance, total_recharged FROM wallets 
WHERE user_id = '[user-id-from-test-2]';
```

Expected: `balance = 0, total_recharged = 0`

---

## Common Issues + Quick Fixes

| Issue | Fix |
|-------|-----|
| "Query executed successfully" but no tables | Run Step 4 verification - tables might already exist |
| Permission denied error | Check Supabase API key in `.env` is `service_role` |
| Foreign key error | Make sure schema.sql runs BEFORE policies.sql |
| Wallet not auto-created | Check trigger exists: `SELECT * FROM information_schema.triggers` |
| Backend can't connect | Restart: `npm run dev` |

---

## File Locations

```
backend/
├── database/
│   ├── schema.sql          ← Deploy this first
│   └── policies.sql        ← Deploy this second
├── .env                    ← Already configured
└── src/services/
    ├── auth.service.ts     ← Updated with Supabase sync
    └── supabase-user.service.ts  ← NEW: handles user sync
```

---

## Architecture After Deployment

```
Firebase Auth         Supabase Database
      ↓                      ↓
  (Login)            (User Profile)
      ↓                      ↓
   ┌────────────────────────────┐
   │   Backend Auth Flow        │
   │ 1. Create Firebase user    │
   │ 2. Sync to Supabase.users  │
   │ 3. Auto-create wallet      │
   │ 4. Return JWT tokens       │
   └────────────────────────────┘
      ↓
  Flutter App
```

---

## What's This Enables

✅ **Immediate After Deployment:**
- User registration + auto-sync to Supabase
- Auto-wallet creation for donors
- Wallet top-ups and donations
- Campaign creation and management
- Messaging system
- RLS security on all data

✅ **Ready for Production:**
- All tables indexed for performance
- Triggers for automatic data updates
- Foreign keys prevent orphaned data
- RLS prevents data leaks between users

---

## Deployment Time

| Step | Time |
|------|------|
| Step 2 (Create Query) | 1 min |
| Step 3 (Execute Schema) | 2 min |
| Step 4 (Create Query 2) | 1 min |
| Step 5 (Execute Policies) | 2 min |
| Step 6 (Verify Tables) | 2 min |
| Step 7 (Verify Policies) | 2 min |
| **Total** | **~12 minutes** |

---

## Success Indicators

✅ You're done when:
1. Both queries executed with "Query executed successfully"
2. Verification Query 1 shows 7 tables
3. Verification Query 2 shows 20+ policies
4. New user registration creates entry in `public.users`
5. New wallet created automatically in `public.wallets`

---

## Next Actions

1. ✅ Run deployment steps above
2. ✅ Run verification queries
3. → Test in Flutter app (register new user)
4. → Test wallet top-up flow
5. → Test donation from wallet

---

**Status**: Ready for deployment
**Time Estimate**: 15 minutes
**Risk Level**: Low (can re-deploy if needed)
