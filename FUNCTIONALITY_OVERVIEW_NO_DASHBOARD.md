# Kindora – Functionality Overview (Backend + Flutter App)

This document lists all implemented functionalities **excluding the React admin dashboard**. It covers the **Node.js backend API** and the **Flutter mobile app**.

---

## 1. Backend API (Node.js / Express / TypeScript)

### 1.1 Authentication (`/api/auth`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/register` | POST | No | Register user (email, password, full_name, role: donor/charity/admin/beneficiary) |
| `/login` | POST | No | Login (email, password); returns tokens |
| `/refresh-token` | POST | No | Refresh access token using refresh_token |
| `/request-password-reset` | POST | No | Request password reset email |
| `/reset-password` | POST | No | Reset password with token |
| `/verify-email/:userId` | GET | No | Verify email |
| `/me` | GET | Yes | Get current user (JWT/Firebase) |

**Implementation:** Full (AuthService + JWT, Firebase integration). Auth middleware resolves Firebase ID token and maps to Supabase user UUID.

---

### 1.2 Campaigns (`/api/campaigns`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/` | GET | No | List campaigns (paginated, filters: status, category, charityId, search) |
| `/` | POST | Yes | Create campaign (charity/beneficiary) |
| `/:campaignId` | GET | No | Get campaign by ID |
| `/:campaignId` | PUT | Yes | Update campaign |
| `/:campaignId/progress` | GET | No | Get campaign progress |
| `/user/recommended` | GET | Yes | Get recommended campaigns for user |

**Implementation:** Full (CampaignService, CampaignController, Joi validation).

---

### 1.3 Donations (`/api/donations`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/` | POST | Yes | Create donation (campaign_id, amount, payment_method: card/wallet/bank_transfer/stripe/payhere) |
| `/history` | GET | Yes | User donation history (paginated) |
| `/total` | GET | Yes | Total donated by user |
| `/recurring` | POST | Yes | Setup recurring donation |
| `/recurring/:donationId` | DELETE | Yes | Cancel recurring donation |
| `/campaign/:campaignId/stats` | GET | No | Campaign donation stats |
| `/stripe/create-intent` | POST | Yes | Create Stripe PaymentIntent |
| `/stripe/confirm-payment` | POST | Yes | Confirm Stripe payment & create donation |
| `/stripe/webhook` | POST | No | Stripe webhook handler |
| `/stripe/publishable-key` | GET | No | Get Stripe publishable key |
| `/wallet/balance` | GET | Yes | User wallet balance |
| `/wallet/transactions` | GET | Yes | User wallet transactions |
| `/confirm-payment` | POST | No | Legacy payment confirmation (e.g. PayHere) |

**Implementation:** Full (DonationService, WalletService, StripeService, validation).

---

### 1.4 Beneficiary Donations (`/api/beneficiary-donations`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/` | POST | Yes | Create beneficiary donation |
| `/history` | GET | Yes | User’s beneficiary donation history |
| `/total` | GET | Yes | Total donated to beneficiary campaigns by user |
| `/campaign/:beneficiary_campaign_id/raised` | GET | No | Total raised for a beneficiary campaign |

**Implementation:** Full (BeneficiaryDonationController, BeneficiaryDonationService).

---

### 1.5 Payments – PayHere (`/api/payments`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/initiate-donation` | POST | Yes | Start PayHere donation (campaignId, amount, message, isAnonymous) |
| `/payhere/notify` | POST | No | PayHere webhook (update donation status, create payment_transaction) |
| `/payhere/return` | GET | No | Redirect after PayHere success |
| `/payhere/cancel` | GET | No | Redirect after PayHere cancel |
| `/status/:donationId` | GET | Yes | Check payment status for a donation |

**Implementation:** Full (PayHereService, notification verification, redirects).

---

### 1.6 Wallet (`/api/wallet`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/balance` | GET | Yes | Wallet balance |
| `/transactions` | GET | Yes | Wallet transactions (paginated) |
| `/details` | GET | Yes | Full wallet details |
| `/initialize` | POST | Yes | Create wallet for user |
| `/topup` | POST | Yes | Top up wallet |

**Implementation:** Full (DonationController delegates to WalletService; Supabase `wallets` table).

---

### 1.7 Beneficiary (`/api/beneficiary`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/profile` | GET | Yes | Get beneficiary profile |
| `/profile` | POST | Yes | Create beneficiary details (NIC, address, bank details) |
| `/profile` | PUT | Yes | Update beneficiary details |
| `/campaigns` | GET | Yes | List current user’s beneficiary campaigns |
| `/campaigns/all` | GET | No | List all beneficiary campaigns (public, paginated) |
| `/campaigns` | POST | Yes | Create beneficiary campaign |
| `/campaigns/:campaignId` | GET | No | Get beneficiary campaign by ID |
| `/campaigns/:campaignId` | PUT | Yes | Update beneficiary campaign |
| `/campaigns/:campaignId` | DELETE | Yes | Delete beneficiary campaign |
| `/campaigns/:campaignId/progress` | GET | No | Get campaign progress |

**Implementation:** Full (BeneficiaryController, BeneficiaryService, Joi schemas).

---

### 1.8 Charity (`/api/charities`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/` | GET | No | Get all charities (stub – returns message only) |
| `/` | POST | No | Create charity (stub) |
| `/:id` | GET | No | Get charity by ID (stub) |
| `/:id` | PUT | No | Update charity (stub) |

**Implementation:** Stub only (placeholder JSON responses).

---

### 1.9 Users (`/api/users`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/` | GET | No | Get all users (stub) |
| `/:id` | GET | No | Get user by ID (stub) |
| `/:id` | PUT | No | Update user (stub) |

**Implementation:** Stub only (placeholder JSON responses).

---

### 1.10 Messages (`/api/messages`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/` | GET | No | Get all messages (stub) |
| `/` | POST | No | Create message (stub) |

**Implementation:** Stub only.

---

### 1.11 Chat – AI Assistant (`/api/chat`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/` | POST | No | Send message; get reply (Gemini API or keyword fallback) |
| `/session/:sessionId` | GET | No | Get chat session history (returns empty array) |
| `/session/:sessionId` | DELETE | No | Clear chat session |

**Implementation:** Full for POST (Gemini + keyword fallback). Session get/delete are placeholders (no persistence).

---

### 1.12 Storage (`/api/storage`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/upload` | POST | Yes | Upload single image (Supabase Storage, multer) |
| `/upload-multiple` | POST | Yes | Upload up to 5 images |
| `/delete` | DELETE | Yes | Delete image by fileName (optional bucket) |

**Implementation:** Full (StorageController, Supabase Storage with SERVICE_ROLE_KEY).

---

### 1.13 Health & Diagnostics

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Status, timestamp, uptime, environment |
| `/diagnostic` | GET | Firebase, Supabase, env vars check |

---

## 2. Flutter App (Mobile)

### 2.1 Authentication & Routing

- **Auth gate:** `AuthGate` checks Firebase `idTokenChanges()`; if not logged in → `LoginScreen`; if logged in → resolves role and profile from Supabase (via repository), then:
  - **Beneficiary:** if profile not completed → `/beneficiary/profile-completion`, else → `/beneficiary/dashboard`
  - **Donor/other:** → `HomeScreen` (then user can navigate to dashboard, etc.)
- **Routes:** GoRouter with `/auth`, `/login`, `/signup`, `/`, `/dashboard`, `/feed`, `/messages`, `/merch`, `/campaigns`, `/profile`, `/profile/settings`, beneficiary routes, `/donor/beneficiary-campaigns`.
- **Main layout:** `MainLayout` (with bottom nav) wraps dashboard, feed, messages, merch, campaigns, profile, beneficiary screens.

**Implementation:** Firebase Auth + Supabase user/role lookup; verify-email and signup screens present.

---

### 2.2 Home & Dashboard

- **Home:** `HomeScreen` – landing with quick actions.
- **Dashboard:** `DashboardScreen` / `DashboardHome` – main app dashboard; links to profile, donor beneficiary campaigns.

**Implementation:** UI and navigation implemented.

---

### 2.3 Campaigns

- **Campaign list:** `CampaignHomePage` – lists campaigns (data from backend API via `CampaignRepository.getAllCampaigns()`).
- **Campaign details:** `CampaignDetailsScreen` – single campaign view.
- **Start campaign:** `StartCampaignPage` – start new campaign flow.
- **Widgets:** `CampaignCard` for list items.

**Implementation:** Repository calls backend `/api/campaigns`; get-by-id also uses Supabase in some paths.

---

### 2.4 Donations & Payments

- **Donation amount:** `DonationAmountSelectionPage`, `BeneficiaryDonationAmountSelectionPage` – choose amount.
- **Payment methods:** `PaymentPage` – payment flow; `PayHerePaymentWebView` – PayHere checkout in WebView; `BankTransferPage` – bank transfer.
- **PayHere:** `PayHerePaymentService` – build payment URL (sandbox/production), hash generation; app can open WebView to PayHere and handle return.
- **Stripe:** `StripeService` (e.g. `flutter_stripe`) and backend Stripe intents used for card payments.

**Implementation:** PayHere WebView and backend PayHere notify/return/cancel implemented; Stripe wired in app and backend.

---

### 2.5 Wallet

- **Balance & history:** `WalletService` – `getWalletBalance()`, `getWalletTransactions()`, `initializeWallet()` calling `/api/wallet/balance`, `/api/wallet/transactions`, `/api/wallet/initialize`.
- **Top-up:** `WalletTopupPage` – UI for topping up; backend `/api/wallet/topup` used.
- **Transaction history:** `WalletTransactionHistoryPage` – list of transactions.

**Implementation:** Full integration with backend wallet API (Firebase ID token for auth).

---

### 2.6 Beneficiary

- **Profile completion:** `BeneficiaryProfileCompletionScreen` – required for new beneficiaries (e.g. NIC, address, bank details).
- **Beneficiary dashboard:** `BeneficiaryDashboardScreen` – overview for beneficiaries.
- **Beneficiary profile:** `BeneficiaryProfileScreen` – view/edit profile.
- **Create campaign:** `BeneficiaryCreateCampaignScreen` – create beneficiary campaign.
- **Campaign detail:** `BeneficiaryCampaignDetailScreen` – single beneficiary campaign.
- **Donor view:** `DonorBeneficiaryCampaignsScreen` – list of beneficiary campaigns for donors (e.g. from dashboard “Donate to individuals”).

**Implementation:** Screens and navigation implemented; backend beneficiary profile and beneficiary-campaign APIs are fully implemented.

---

### 2.7 Chat – AI Assistant

- **UI:** `ChatWindow`, `ChatAssistantButton` – open chat overlay.
- **Service:** `ChatService` – POST to backend `/api/chat` with sessionId, message, conversationHistory; displays reply.
- **State:** `ChatProvider` (e.g. Riverpod); models in `chat_model.dart`.

**Implementation:** Full for sending messages and showing replies (backend uses Gemini or keyword fallback).

---

### 2.8 Feed, Messages, Merch

- **Feed:** `FeedPage` – feed UI (backend has no dedicated feed API; can use campaigns or placeholder).
- **Messages:** `MessagesPage` – messages list (backend messages are stubs).
- **Merch:** `MerchPage` – merchandise/marketplace UI (backend has Product/Order models but no dedicated merch API in routes).

**Implementation:** UI present; backend support for messages/merch is minimal or stub.

---

### 2.9 Profile & Settings

- **Profile:** `ProfilePage` – user profile; can navigate to settings; logout → `/login`.
- **Settings:** `SettingsPage` – app settings (e.g. theme, language).
- **Theme:** `ThemeProvider` (e.g. dark/light).
- **Language:** `LanguageProvider`; localizations: `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_ta.dart`, `app_localizations_si.dart`.

**Implementation:** Profile and settings screens; theme and language toggles; localization files present.

---

### 2.10 Config & Infrastructure

- **Env:** `flutter_dotenv` for `.env`; `AppEnv.apiBaseUrl` for API base URL; `AppConfig` constants.
- **Supabase:** `SupabaseService` – client, `userId` from Supabase Auth (used alongside Firebase).
- **Firebase:** Core, Auth, Firestore, Messaging, Storage, Analytics – initialized in `main.dart`; `firebase_options.dart` for config.
- **Router:** `AppRouter` – GoRouter with all routes and `ShellRoute` for main layout.

---

## 3. Summary Table (Excluding React Dashboard)

| Area | Backend | Flutter App |
|------|---------|-------------|
| **Auth** | ✅ Full (register, login, refresh, reset, verify, /me) | ✅ Auth gate, login, signup, verify email |
| **Campaigns** | ✅ Full CRUD, list, progress, recommended | ✅ List, details, start campaign |
| **Donations** | ✅ Create, history, total, recurring, Stripe, wallet | ✅ Amount selection, payment page, PayHere WebView, Stripe |
| **Beneficiary donations** | ✅ Create, history, total, raised | ✅ Beneficiary donation amount page |
| **PayHere** | ✅ Initiate, notify, return, cancel, status | ✅ WebView checkout, config, hash |
| **Wallet** | ✅ Balance, transactions, init, topup, details | ✅ Balance, history, top-up pages, WalletService |
| **Beneficiary** | ✅ Profile CRUD, campaign CRUD, progress | ✅ Profile completion, dashboard, profile, create campaign, campaign detail, donor list |
| **Charity** | ⚠️ Stub only | — |
| **Users** | ⚠️ Stub only | — (profile uses auth + Supabase) |
| **Messages** | ⚠️ Stub only | ✅ Messages page UI |
| **Chat (AI)** | ✅ Gemini + keyword fallback | ✅ Chat window, button, service, provider |
| **Storage** | ✅ Upload single/multiple, delete (Supabase) | Used indirectly (e.g. campaign images) |
| **Health/Diagnostic** | ✅ /health, /diagnostic | — |

---

## 4. Gaps / Stubs (No Dashboard)

- **Charity API:** Routes exist but return placeholder JSON; no real CRUD.
- **User API:** Same – placeholder responses only.
- **Messages API:** Stub only; Flutter has Messages page but no real backend.
- **Chat session persistence:** Session get/delete do not persist messages (in-memory/empty).
- **Database folder:** README mentions `database/` for SQL schema; no schema files found in repo (likely in Supabase or separate docs).

This overview is the single reference for “all functionalities without react dashboard” (backend + Flutter only).
