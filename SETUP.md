# Developer Setup Guide - Kindora Platform

## Prerequisites

Before starting, ensure you have the following installed:

- Node.js 18+ ([Download](https://nodejs.org/))
- Flutter SDK 3.10+ ([Download](https://flutter.dev/docs/get-started/install))
- PostgreSQL 13+ ([Download](https://www.postgresql.org/download/))
- Git

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

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=kindora

# Firebase (Get from Firebase Console)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email

# JWT
JWT_SECRET=your-secret-key

# PayHere (Get test credentials from PayHere)
PAYHERE_MERCHANT_ID=your-merchant-id
PAYHERE_MERCHANT_SECRET=your-merchant-secret
```

### 3. Initialize Database

```bash
# Create database
psql -U postgres --no-password -c "CREATE DATABASE kindora;"

# Run schema
psql -U postgres kindora < ../database/schema.sql
```

### 4. Start Development Server

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

### 2. Environment Configuration

```bash
# Create .env.local
echo "REACT_APP_API_URL=http://localhost:5000/api" > .env.local
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

### 2. Firebase Configuration

#### Android:
1. Get `google-services.json` from Firebase Console
2. Place in `flutter_app/android/app/`

#### iOS:
1. Get `GoogleService-Info.plist` from Firebase Console
2. Place in `flutter_app/ios/Runner/`

### 3. Run App

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

## Database Setup

### Create Database

```bash
psql -U postgres --no-password -c "CREATE DATABASE kindora;"
```

### Run Migrations

```bash
psql -U postgres kindora < database/schema.sql
```

### View Tables

```bash
psql -U postgres kindora
\dt
```

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

## Common Issues

### PostgreSQL Connection Refused

```bash
# Check if PostgreSQL is running
pg_isready -h localhost -p 5432

# Start PostgreSQL (Mac with Homebrew)
brew services start postgresql

# Start PostgreSQL (Linux)
sudo systemctl start postgresql
```

### Flutter Version Issues

```bash
flutter upgrade
flutter pub get
```

### Port Already in Use

```bash
# Find process using port 5000
lsof -i :5000

# Kill process
kill -9 <PID>
```

### Firebase Initialization Error

Ensure Firebase credentials in `.env` are valid. Check:
- FIREBASE_PROJECT_ID
- FIREBASE_PRIVATE_KEY (with proper newlines)
- FIREBASE_CLIENT_EMAIL

## Development Tips

1. **Hot Reload**: Press `r` in Flutter terminal for hot reload
2. **Debug Console**: Use `console.log()` in Node.js, `print()` in Dart
3. **Database Inspection**: Use pgAdmin or DBeaver for visual database management
4. **API Testing**: Use Postman or Thunder Client for API testing
5. **State Management**: Follow Redux pattern in React, Provider pattern in Flutter

## API Documentation

See [API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md) for full API reference.

## Project Structure

```
kindora/
├── backend/              # Node.js API
│   ├── src/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── routes/
│   │   ├── middleware/
│   │   └── index.ts
│   └── package.json
├── react_dashboard/      # Admin Dashboard
├── flutter_app/          # Mobile App
└── database/            # Database files
```

## Next Steps

1. ✅ Install dependencies
2. ✅ Set up database
3. ✅ Configure environment
4. ✅ Start backend server
5. ✅ Start React dashboard
6. ✅ Start Flutter app
7. ✅ Test API endpoints
8. ✅ Implement features from Phase 2

## Support

For issues or questions:
- Check existing GitHub issues
- Create a new GitHub issue
- Contact the development team

---

Happy coding! 🚀
