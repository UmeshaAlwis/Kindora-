# Developer Setup Guide - Kindora Platform

## Prerequisites

Before starting, ensure you have the following installed:

- Node.js 18+ ([Download](https://nodejs.org/))
- Flutter SDK 3.10+ ([Download](https://flutter.dev/docs/get-started/install))
- Git
- **🟢 Supabase CLI ([Install](https://supabase.com/docs/guides/cli))**

## 🟢 Supabase Setup

### 🟢 1. Create Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Click "New Project"
3. Fill in project details:
   - **Name**: kindora
   - **Database Password**: (save this securely)
   - **Region**: Choose the closest to your users
4. Wait for project initialisation (~2 minutes)

### 🟢 2. Get Supabase Credentials

From your Supabase project dashboard:
- **Project URL**: `https://xxxxx.supabase.co`
- **anon/public key**: Found in Settings > API
- **service_role key**: Found in Settings > API (keep secret!)
- **Database connection string**: Found in Settings > Database

## Backend Setup

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Environment Configuration
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```env
NODE_ENV=development
PORT=5000

# 🟢 Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# 🟢 Database (from Supabase Settings > Database)
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres

# 🟢 Firebase Cloud Messaging ONLY (Get from Firebase Console)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_SERVER_KEY=your-fcm-server-key

# JWT (🟢 Supabase handles this, but for custom tokens if needed)
JWT_SECRET=your-secret-key

# PayHere (Get test credentials from PayHere)
PAYHERE_MERCHANT_ID=your-merchant-id
PAYHERE_MERCHANT_SECRET=your-merchant-secret
```

### 🟢 3. Initialize Database

**🟢 Option A: Using Supabase Dashboard (Recommended)**

1. Go to Supabase Dashboard > SQL Editor
2. Copy and paste contents from `database/schema.sql`
3. Click "Run"

**🟢 Option B: Using Supabase CLI**
```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

**🟢 Option C: Using psql directly**
```bash
psql "postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres" < database/schema.sql
```

### 🟢 4. Set Up Row Level Security (RLS)

In Supabase Dashboard > Authentication > Policies, enable RLS for tables:
```sql
-- Example: Enable RLS on the campaigns table
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read campaigns
CREATE POLICY "Allow authenticated users to read campaigns"
ON campaigns FOR SELECT
TO authenticated
USING (true);

-- See database/policies.sql for complete RLS setup
```

### 5. Start Development Server
```bash
npm run dev
```

Server runs at: `http://localhost:5000`

## React Dashboard Setup

### 1. Install Dependencies
```bash
cd react_dashboard
npm install
```

### 🟢 2. Environment Configuration
```bash
cp .env.example .env.local
```

🟢 Edit `.env.local`:
```env
VITE_API_URL=http://localhost:5000/api
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### 3. Start Development Server
```bash
npm run dev
```

Dashboard runs at: `http://localhost:5173`

## Flutter App Setup

### 1. Get Dependencies
```bash
cd flutter_app
flutter pub get
```

### 🟢 2. Supabase Configuration

🟢 Edit `lib/core/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
}
```

### 🟢 3. Firebase Cloud Messaging Configuration

#### Android:
1. Get `google-services.json` from Firebase Console
2. Place in `flutter_app/android/app/`

#### iOS:
1. Get `GoogleService-Info.plist` from Firebase Console
2. Place in `flutter_app/ios/Runner/`

### 🟢 4. Initialize Supabase in App

🟢 Ensure `lib/main.dart` initializes Supabase:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(MyApp());
}
```

### 5. Run App

**On Android Emulator:**
```bash
flutter emulators --launch Pixel_4_API_30
flutter run
```

**On iOS Simulator:**
```bash
open -a Simulator
flutter run
```

**On Physical Device:**
```bash
flutter devices
flutter run -d <device-id>
```

## 🟢 Database Management

### 🟢 View Tables via Supabase Dashboard

1. Go to Supabase Dashboard > Table Editor
2. Browse and edit tables visually

### 🟢 Using SQL Editor

1. Go to Supabase Dashboard > SQL Editor
2. Run queries directly:
```sql
-- View all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- View campaigns
SELECT * FROM campaigns LIMIT 10;
```

### 🟢 Using pgAdmin or DBeaver

Connect using the connection string from Supabase Settings > Database

## Testing

### Backend Tests
```bash
cd backend
npm run test
npm run test:watch
```

### Flutter Tests
```bash
cd flutter_app
flutter test
```

## Linting & Formatting

### Backend
```bash
cd backend

# Lint
npm run lint

# Format
npm run format
```

### 🟢 Flutter
```bash
cd flutter_app

# Analyze
flutter analyze

# Format
dart format .
```

## Common Issues

### 🟢 Supabase Connection Issues
```bash
# Test connection
curl https://xxxxx.supabase.co/rest/v1/

# Check API keys
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY
```

### 🟢 Flutter Supabase Package Issues
```bash
flutter pub upgrade supabase_flutter
flutter pub get
flutter clean
flutter run
```

### Port Already in Use
```bash
# Find process using port 5000
lsof -i :5000

# Kill process
kill -9 <PID>
```

### 🟢 Firebase Cloud Messaging Not Working

Ensure:
- `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in correct location
- Firebase project has Cloud Messaging enabled
- FIREBASE_SERVER_KEY is correct in backend `.env`

### 🟢 RLS (Row Level Security) Blocking Queries

Check policies in Supabase Dashboard > Authentication > Policies

Temporarily disable for testing:
```sql
ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
```

## Development Tips

1. **🟢 Supabase Realtime**: Use for live updates on donations, campaigns
2. **Hot Reload**: Press `r` in Flutter terminal for hot reload
3. **Debug Console**: Use `console.log()` in Node.js, `print()` in Dart
4. **🟢 Database Inspection**: Use Supabase Table Editor for visual management
5. **API Testing**: Use Postman or Thunder Client for API testing
6. **🟢 Supabase Auth**: Leverage built-in authentication instead of custom JWT
7. **🟢 Storage**: Use Supabase Storage for campaign images, receipts, etc.

## 🟢 Supabase Features to Leverage

### 🟢 Authentication
- Email/Password login ✅
- Google OAuth ✅
- Magic link login
- Phone/SMS authentication

### 🟢 Database
- PostgreSQL with full SQL support ✅
- Real-time subscriptions ✅
- Row Level Security (RLS) ✅

### 🟢 Storage
- File uploads for campaign images
- Donor receipts and documents
- Profile pictures

### 🟢 Edge Functions
- Serverless functions for complex logic
- Payment webhooks
- Scheduled tasks

## API Documentation

See [API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md) for full API reference.

## 🟢 Project Structure
```
kindora/
├── backend/              # Node.js API
│   ├── src/
│   │   ├── controllers/
│   │   ├── services/
│   │   │   ├── 🟢 supabase.service.ts
│   │   │   ├── 🟢 fcm.service.ts
│   │   │   └── payment.service.ts
│   │   ├── routes/
│   │   ├── middleware/
│   │   └── index.ts
│   └── package.json
├── react_dashboard/      # Admin Dashboard
│   ├── src/
│   │   ├── lib/
│   │   │   └── 🟢 supabaseClient.ts
│   │   └── components/
│   └── package.json
├── flutter_app/          # Mobile App
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/
│   │   │   │   └── 🟢 supabase_config.dart
│   │   │   └── services/
│   │   │       ├── 🟢 supabase_service.dart
│   │   │       └── 🟢 fcm_service.dart
│   │   └── features/
│   └── pubspec.yaml
└── database/            # Database files
    ├── schema.sql
    └── 🟢 policies.sql     # RLS policies
```

## 🟢 Deployment Considerations

### 🟢 Backend Deployment
- Deploy to Vercel, Railway, or Render
- Set environment variables in platform dashboard
- Ensure DATABASE_URL points to Supabase production database

### 🟢 Supabase Production
- Project is already hosted by Supabase
- Enable backups in Supabase Dashboard
- Set up database migrations workflow
- Monitor usage in Supabase Dashboard > Reports

### 🟢 Flutter App Deployment
- **Android**: Build APK/AAB for Google Play Store
- **iOS**: Build IPA for Apple App Store
- Update Supabase URLs to production in config

## Next Steps

1. ✅ 🟢 Create Supabase project
2. ✅ Install dependencies
3. ✅ 🟢 Set up database schema
4. ✅ 🟢 Configure RLS policies
5. ✅ Configure environment variables
6. ✅ Start backend server
7. ✅ Start React dashboard
8. ✅ Start Flutter app
9. ✅ 🟢 Test Supabase authentication
10. ✅ 🟢 Test FCM notifications
11. ✅ Implement features from Phase 2

## 🟢 Useful Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [PayHere Integration Guide](https://support.payhere.lk/api-&-mobile-sdk)

## Support

For issues or questions:
- 🟢 Check [Supabase Discord](https://discord.supabase.com/)
- Check existing GitHub issues
- Create a new GitHub issue
- Contact the development team

---

Happy coding! 🚀
