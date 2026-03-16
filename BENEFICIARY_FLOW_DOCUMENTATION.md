# Beneficiary User Flow Documentation

## Overview
This document outlines the complete beneficiary user flow implementation in the Kindora app. Beneficiaries can register, complete their profile, and create fundraising campaigns (GoFundMe-style).

## User Journey

### 1. Registration → First Login
1. User selects "Beneficiary" during signup
2. Firebase account is created
3. Backend creates user profile with `role = 'beneficiary'`
4. User is redirected to `/beneficiary/profile-completion`

### 2. Profile Completion
**Screen**: `BeneficiaryProfileCompletionScreen`
- **Step 1: Personal Details**
  - Full Name (required)
  - NIC - National ID (required)
  - Address (required)
- **Step 2: Bank Details**
  - Bank Name (required)
  - Bank Code (required)
  - Account Holder Name (required)
  - Account Number (required)
  - Security note displayed about data protection

**Action**: Saves to `beneficiary_details` table with `profile_completed = true`

### 3. Dashboard Access
**Screen**: `BeneficiaryDashboardScreen`
- Shows welcome message with user email
- **Quick Actions Panel**:
  - New Campaign button → `/beneficiary/create-campaign`
  - My Profile button → `/beneficiary/profile`
- **My Campaigns Section**:
  - List of all campaigns created by user
  - Each campaign card shows:
    - Campaign image
    - Title
    - Progress bar (raised vs target)
    - Raised amount and goal
    - Status badge (ACTIVE/COMPLETED/PAUSED)

### 4. Create Campaign (GoFundMe-style)
**Screen**: `BeneficiaryCreateCampaignScreen`
- Campaign image picker
- Campaign title (min 10 chars, max 100 chars)
- Campaign story/description (min 50 chars)
- Fundraising goal (target amount)
- All fields validated before submission
- Image uploaded to Supabase
- Campaign saved to `beneficiary_campaigns` table

### 5. View/Edit Profile
**Screen**: `BeneficiaryProfileScreen`
- **View Mode**: Shows all personal and bank details in read-only format
- **Edit Mode**: Allows updating all fields except NIC (for security)
- Profile header with user avatar and email
- Changes saved back to database

## Database Schema

### beneficiary_details
```sql
id              UUID PRIMARY KEY
user_id         UUID (REFERENCES auth.users)
full_name       VARCHAR NOT NULL
nic             VARCHAR NOT NULL UNIQUE
address         TEXT NOT NULL
bank_account_holder_name VARCHAR NOT NULL
bank_account_number VARCHAR NOT NULL
bank_name       VARCHAR NOT NULL
bank_code       VARCHAR NOT NULL
profile_completed BOOLEAN DEFAULT false
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

### beneficiary_campaigns
```sql
id                  UUID PRIMARY KEY
beneficiary_user_id UUID (REFERENCES auth.users)
full_name           VARCHAR NOT NULL
title               VARCHAR NOT NULL
description         TEXT NOT NULL
target_amount       DECIMAL NOT NULL
raised_amount       DECIMAL DEFAULT 0
image_url           VARCHAR
status              VARCHAR DEFAULT 'active'
created_at          TIMESTAMP
updated_at          TIMESTAMP
```

## Architecture

### Models (lib/models/supabase_models.dart)
- `BeneficiaryDetails`: Data model for personal details
- `BeneficiaryCampaign`: Data model for campaigns

### Repositories (lib/repositories/supabase_repositories.dart)
- `BeneficiaryDetailsRepository`: CRUD operations for profiles
- `BeneficiaryCampaignRepository`: CRUD operations for campaigns

### Providers (lib/providers/supabase_providers.dart)
- Repository providers for dependency injection
- FutureProviders for data fetching with Riverpod

### UI Screens (lib/features/beneficiary/ui/)
1. `beneficiary_profile_completion_screen.dart`: Onboarding
2. `beneficiary_dashboard_screen.dart`: Main hub
3. `beneficiary_profile_screen.dart`: Profile management
4. `beneficiary_create_campaign_screen.dart`: Campaign creation

### Routes (lib/config/routes/app_router.dart)
- `/beneficiary/profile-completion`: Profile setup
- `/beneficiary/dashboard`: Main dashboard
- `/beneficiary/profile`: Profile view/edit
- `/beneficiary/create-campaign`: Create campaign
- `/beneficiary/campaigns`: All campaigns
- `/beneficiary/campaign/:id`: Campaign details

### Auth Flow (lib/core/widgets/auth_gate.dart)
- Checks user role from Supabase `profiles` table
- For beneficiaries: Verifies profile completion status
- Routes accordingly:
  - Not completed → Profile completion screen
  - Completed → Beneficiary dashboard
  - Other roles → Home screen

## Validations

### Profile Completion
- Full Name: min 3 chars
- NIC: required (non-empty)
- Address: min 10 chars
- Bank fields: all required

### Campaign Creation
- Title: min 10, max 100 chars
- Description: min 50 chars
- Target Amount: > 0 and valid number
- Image: optional but recommended

## API Integrations

### Image Upload
- Uses `/upload` endpoint to save campaign images
- Base64 encoded upload to Supabase Storage
- File path: `beneficiary_campaigns/{timestamp}.png`

### Data Persistence
- All data saved to Supabase directly from repositories
- Real-time data fetching with Riverpod providers
- Cache invalidation available via `beneficiaryRefreshProvider`

## Future Enhancement Ideas

### Phase 2: Donations
- Donation contribution system
- Payment processing (Stripe integration)
- Donation notifications
- Donor profile/messaging

### Phase 3: Analytics
- Campaign statistics/insights
- Fundraising progress charts
- Beneficiary verification badges
- Campaign updates/news posts

### Phase 4: Advanced Features
- Withdrawal requests management
- Transaction history
- Beneficiary support/chat
- Campaign recommendation system
- Social sharing integration

## Testing Scenarios

1. **First-time beneficiary**:
   - Sign up as beneficiary
   - Should redirect to profile completion
   - Fill all required fields
   - Should redirect to dashboard

2. **Create campaign**:
   - Upload campaign image
   - Fill campaign details
   - Submit and verify in dashboard

3. **Update profile**:
   - Edit profile button
   - Change personal details
   - Save and verify changes persisted

4. **Role-based access**:
   - Beneficiary sees dashboard with creation options
   - Donor sees regular dashboard
   - Correct role-based routing works

## Notes
- Bank details are securely stored and used only for fund transfers
- NIC cannot be edited after initial setup
- Campaigns can have multiple status states (active, paused, completed)
- Progress bars are calculated from raised vs target amounts
- All timestamps are UTC
