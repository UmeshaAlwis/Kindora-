# Firebase + Supabase Auth Sync Integration

## Overview

Kindora now uses a **dual-auth system** that combines the best of both worlds:

- **Firebase Auth**: Handles authentication (user login, password, token management)
- **Supabase Users Table**: Stores user profiles and enables RLS policies

When a user registers, the system automatically syncs their data across both platforms.

## Architecture

```
Registration Flow:
┌──────────────────────────────────┐
│ 1. Check email doesn't exist      │
└──────────────────┬────────────────┘
                   │
┌──────────────────▼────────────────┐
│ 2. Create Firebase Auth User      │
│    (get Firebase UID)             │
└──────────────────┬────────────────┘
                   │
┌──────────────────▼────────────────┐
│ 3. Sync to Supabase users table   │
│    (public.users)                 │
└──────────────────┬────────────────┘
                   │
┌──────────────────▼────────────────┐
│ 4. Create user wallet in Supabase │
│    (auto-initialized to 0 balance)│
└──────────────────┬────────────────┘
                   │
┌──────────────────▼────────────────┐
│ 5. Create in local database       │
│    (backward compatibility)       │
└──────────────────┬────────────────┘
                   │
┌──────────────────▼────────────────┐
│ 6. Generate JWT tokens            │
│    (return to Flutter app)        │
└──────────────────────────────────┘
```

## Database Changes

### 1. New Users Table in Supabase

**File**: `backend/database/schema.sql`

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  full_name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  role VARCHAR(50) NOT NULL DEFAULT 'donor',
  profile_picture_url TEXT,
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  email_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. Updated Foreign Keys

All tables now reference `users(id)` instead of `auth.users(id)`:
- `campaigns.user_id` → `users(id)`
- `donations.user_id` → `users(id)`
- `wallets.user_id` → `users(id)`
- `messages.sender_id` → `users(id)`
- `messages.recipient_id` → `users(id)`

### 3. New RLS Policies

Users can only view/modify their own profile data via RLS policies.

## Backend Implementation

### New Service: SupabaseUserService

**File**: `backend/src/services/supabase-user.service.ts`

**Methods**:
- `createUser(firebaseUid, registrationData, userId)` - Sync Firebase user to Supabase
- `createWallet(userId)` - Auto-create wallet for new user
- `getUserByFirebaseUid(firebaseUid)` - Lookup user by Firebase UID
- `updateLastLogin(userId)` - Sync last login timestamp
- `updateUser(userId, updates)` - Update user profile
- `verifyEmail(userId)` - Mark email as verified

### Updated AuthService

**File**: `backend/src/services/auth.service.ts`

**Changes**:
- **Register**: Now syncs to Supabase after Firebase registration
  1. Creates Firebase user
  2. Syncs to Supabase users table
  3. Creates wallet in Supabase
  4. Creates in local database (backup)
  
- **Login**: Now updates last_login in Supabase

**Registers: Non-blocking Supabase failures**
- If Supabase sync fails, user can still login (Firebase source of truth)
- Wallet creation failures don't block registration (may autocreate via trigger)

## Data Flow

```
User Registration (Flutter App)
        │
        ▼
POST /api/auth/register
        │
        ▼
AuthController.register()
        │
        ▼
AuthService.register()
        │
        ├─► Check email in Supabase + LocalDB
        ├─► Create Firebase user (get UID)
        ├─► SupabaseUserService.createUser()
        │   └─► INSERT into public.users
        ├─► SupabaseUserService.createWallet()
        │   └─► INSERT into public.wallets
        ├─► Create in local database
        ├─► Initialize gamification (donors)
        └─► Generate JWT tokens
        │
        ▼
Response: {access_token, refresh_token, user}
        │
        ▼
Flutter App stores tokens & user data
```

## Data Sync Points

### On Registration
✅ Firebase Auth created
✅ Supabase users table updated
✅ Supabase wallet created
✅ Local database updated

### On Login
✅ Local database updated (last_login)
✅ Supabase updated (last_login) - non-blocking

### On User Updates (future)
- Profile picture: Update Supabase + Firebase
- Phone number: Update Supabase + Firebase
- Email change: Handle via Firebase email verification

## Deployment Instructions

### Step 1: Update Database Schema

```bash
# In Supabase SQL Editor, run:
backend/database/schema.sql

# Then run RLS policies:
backend/database/policies.sql
```

### Step 2: Update Backend Environment

No changes needed - backend `.env` already has Supabase credentials.

### Step 3: Test Registration

```bash
# Start backend
cd backend
npm run dev

# In Flutter app or Postman, register a user:
POST http://localhost:5001/api/auth/register
{
  "email": "test@example.com",
  "password": "password123",
  "full_name": "Test User",
  "role": "donor",
  "phone_number": "0701234567"
}
```

### Step 4: Verify Data Sync

Check 3 places for the user:

1. **Firebase Console**
   - Go to Firebase Project → Authentication
   - Verify user email exists

2. **Supabase SQL Editor**
   ```sql
   SELECT * FROM users WHERE email = 'test@example.com';
   ```

3. **Supabase Wallet**
   ```sql
   SELECT * FROM wallets WHERE user_id = '[user-id]';
   ```

## Troubleshooting

### Issue: User created in Firebase but not in Supabase

**Cause**: Supabase API credentials invalid

**Solution**:
- Verify `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in `.env`
- Check Supabase dashboard for correct keys
- Restart backend: `npm run dev`

**Logs to check**:
```
[SupabaseUserService] Failed to create user
[AuthService] Supabase sync failed
```

### Issue: Wallet not created for new user

**Cause**: Either trigger didn't work or wallet creation failed

**Solution**:
- Check if `wallets_create_on_user_signup` trigger exists
- Manually verify:
  ```sql
  SELECT COUNT(*) FROM wallets WHERE user_id = '[user-id]';
  ```
- If empty, manually create:
  ```sql
  INSERT INTO wallets (user_id, balance) 
  VALUES ('[user-id]', 0);
  ```

### Issue: "Email already registered" but not in database

**Cause**: User exists in Supabase but not local DB

**Solution**: Either:
1. Delete from Supabase and re-register, or
2. Manually create in local database

### Issue: Last login not syncing to Supabase

**Cause**: Non-blocking error - Supabase operation failed but login succeeded

**Solution**: Check backend logs for Supabase update errors, but login is still valid.

## Migration from Firebase-Only Auth

If you had previous users in Firebase but not in Supabase:

```bash
# Migration script (to be run once)
# backend/scripts/migrate-firebase-users.ts

import { admin } from './firebase.service';
import { SupabaseUserService } from './services/supabase-user.service';

export async function migrateFirebaseUsers() {
  const listUsersResult = await admin.auth().listUsers(1000);
  
  for (const firebaseUser of listUsersResult.users) {
    try {
      const existingUser = await SupabaseUserService.getUserByFirebaseUid(
        firebaseUser.uid
      );
      
      if (!existingUser) {
        // Create in Supabase
        await SupabaseUserService.createUser(
          firebaseUser.uid,
          {
            email: firebaseUser.email!,
            password: 'temp', // Not used
            full_name: firebaseUser.displayName || 'User',
            role: 'donor', // Default role
          },
          firebaseUser.uid // Use Firebase UID as users.id
        );
        console.log('Migrated:', firebaseUser.email);
      }
    } catch (error) {
      console.error('Migration failed for', firebaseUser.email, error);
    }
  }
}
```

## Security Notes

✅ **Firebase Auth is source of truth** for authentication
- Password hashing: Firebase handles this
- Token generation: Backend JWT (signed with JWT_SECRET)
- Session management: Firebase SDK manages tokens

✅ **Supabase RLS protects data access**
- Users can only query their own profiles
- Wallet data protected by RLS
- Sensitive data stays in Supabase, not in local DB

✅ **User profiles in Supabase enable**
- Sharing profiles between users (public view)
- Campaign creator info visible to donors
- Donor name visible on donations
- All protected by RLS policies

## Future Enhancements

1. **Profile Picture Upload**: Store in Supabase Storage, update users.profile_picture_url
2. **Email Verification**: Firebase sends email → update users.email_verified after verification
3. **User Deactivation**: Set users.is_active = FALSE
4. **Role-based Access**: Flutter filters UI based on users.role
5. **Sync Metadata**: Store custom user data in users.metadata JSONB field

## Testing Checklist

- [ ] Register new user → verify in all 3 places (Firebase, Supabase users, Supabase wallets)
- [ ] Login user → verify last_login updated in Supabase
- [ ] Query campaigns → verify user_id matches users table
- [ ] Make donation → verify wallet transaction created
- [ ] Test RLS → verify users can't see other users' wallets
- [ ] Test profile update → changes sync to Supabase

---

**Last Updated**: March 12, 2026
**Status**: Ready for deployment
**Next Step**: Run schema.sql and policies.sql in Supabase
