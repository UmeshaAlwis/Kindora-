# Wallet Top-Up Implementation Guide

## ✅ Status: FULLY FUNCTIONAL (Demo/Mock Mode)

A complete dummy/mock wallet top-up system is now fully implemented and operational until Stripe integration is complete.

---

## 🏗️ Architecture Overview

### Frontend (Flutter)
**Files Modified:**
- `wallet_topup_page.dart` - UI for amount selection and processing
- `wallet_service.dart` - HTTP client for backend communication

### Backend (Node.js/TypeScript)
**Files Modified:**
- `donation.controller.ts` - topUpWallet endpoint handler
- `wallet.service.ts` - Wallet balance update logic

### Database
**Schema Used:**
- `wallets` table - Stores balance and recharge history
- `wallet_transactions` table - Records all top-up/spend transactions

---

## 🔄 Complete Flow

### 1. User Initiates Top-Up (Flutter)
```dart
WalletTopUpPage
  ↓
User selects amount (quick button or custom input)
  ↓
_topUp(amount) called
  ↓
WalletService.topUpWallet() called with amount
```

### 2. Frontend Sends Request
```dart
POST ${AppEnv.apiBaseUrl}/wallet/topup
Headers:
  - Authorization: Bearer ${idToken}
  - Content-Type: application/json

Body:
{
  "amount": 5000.0,
  "payment_method": "demo"
}
```

### 3. Backend Processes Top-Up (Node.js)
```typescript
DonationController.topUpWallet()
  ↓
Extract userId from JWT
  ↓
Validate amount > 0
  ↓
WalletService.addToWallet(userId, amount, reference_id)
  ↓
1. Get wallet_id from Supabase
  ↓
2. Create transaction record in wallet_transactions
  ↓
3. Update wallet balance in Supabase
   - balance += amount
   - total_recharged += amount
  ↓
Return updated wallet data
```

### 4. Frontend Handles Response
```dart
Success:
  ✓ Show success snackbar: "Successfully added LKR 5000 to wallet!"
  ✓ Clear input field
  ✓ Wait 1 second
  ✓ Pop back to previous screen (return true for refresh)

Error:
  ✗ Show error snackbar with error message
  ✗ Keep on topup page for retry
```

---

## 📊 Data Model

### Wallet Table
```sql
CREATE TABLE wallets (
  wallet_id UUID PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE,
  balance DECIMAL(15, 2),           -- Current balance
  total_recharged DECIMAL(15, 2),    -- Lifetime total added
  total_spent DECIMAL(15, 2),        -- Lifetime total used
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### Wallet Transactions Table
```sql
CREATE TABLE wallet_transactions (
  transaction_id UUID PRIMARY KEY,
  wallet_id UUID NOT NULL,
  type VARCHAR(10),                  -- 'credit' or 'debit'
  amount DECIMAL(15, 2),
  reference_id VARCHAR(255),         -- 'topup_${timestamp}'
  description TEXT,                  -- 'Wallet recharge'
  timestamp TIMESTAMP
)
```

---

## 🔧 API Endpoint

### POST `/api/wallet/topup`

**Authentication:** Required (Firebase JWT Token)

**Request Body:**
```json
{
  "amount": 5000,
  "payment_method": "demo"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid-here",
    "amount_added": 5000,
    "new_balance": 5000,
    "total_recharged": 5000,
    "message": "Wallet top-up successful (Demo mode)"
  },
  "message": "Wallet top-up successful"
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "User not authenticated",
  "status": 401
}
```

---

## 🧪 Testing the Implementation

### Manual Testing Steps:

1. **Navigate to Wallet Top-Up:**
   - Open Dashboard → Click "Top Up Wallet" button
   - Should navigate to WalletTopUpPage

2. **Select Amount:**
   - Click one of the preset amounts (500, 1000, 2500, 5000)
   - Or enter custom amount in text field

3. **Process Top-Up:**
   - Click "Top Up Wallet" button
   - Button shows loading spinner
   - Wait for response...

4. **Expected Success:**
   - Green snackbar: "Successfully added LKR XXXX to wallet! (Demo Mode)"
   - Page pops back after 1 second
   - Wallet balance should increase

5. **Expected Errors:**
   - Empty amount: "Please enter a valid amount"
   - Network error: "Error topping up wallet: [error message]"
   - Backend error: "Failed to top-up wallet: 500" or detailed error

---

## 💾 Database Transactions

### Top-Up Process Creates:
1. **wallet_transactions record** (type: 'credit')
   - Amount: specified by user
   - Reference: `topup_${timestamp}`
   - Description: 'Wallet recharge'

2. **Updates wallets record**
   - balance += amount
   - total_recharged += amount
   - updated_at = now()

### Example Transaction Record:
```json
{
  "transaction_id": "uuid-xxx",
  "wallet_id": "uuid-yyy",
  "type": "credit",
  "amount": 5000,
  "reference_id": "topup_1710419234567",
  "description": "Wallet recharge",
  "timestamp": "2026-03-14T14:47:14.567Z"
}
```

---

## 🔐 Security Features

✅ **JWT Authentication:**
- All requests require valid Firebase JWT token
- User ID extracted from token

✅ **Input Validation:**
- Amount must be positive number > 0
- Returns 400 Bad Request if invalid

✅ **User Isolation:**
- Each user can only update their own wallet
- user_id from JWT prevents cross-user access

✅ **Transaction Logging:**
- Every top-up creates immutable transaction record
- Audit trail for all wallet changes

---

## 🚀 Migration to Stripe (Future)

### What Needs to Change:

**Frontend (wallet_topup_page.dart):**
```dart
// Current:
await _walletService.topUpWallet(
  amount: amount,
  paymentMethodId: 'demo'
);

// Future (with Stripe):
// 1. Open Stripe payment sheet
// 2. Collect card details
// 3. Call backend with payment intent confirmation
// 4. Backend verifies with Stripe
// 5. Only then update wallet
```

**Backend (donation.controller.ts):**
```typescript
// Current:
const updatedWallet = await WalletService.addToWallet(userId, amount);

// Future:
// 1. Verify Stripe payment intent
// 2. Confirm charge with Stripe
// 3. Only update wallet if Stripe confirms payment
// 4. Handle payment failures gracefully
```

### Stripe Integration Points:
- Add `STRIPE_SECRET_KEY` to `.env`
- Use Stripe client library for payment processing
- Add payment verification before wallet update
- Handle webhook confirmations for async payments

---

## 📋 Requirements Implemented

- ✅ User can select top-up amount (preset or custom)
- ✅ Amount validation (must be > 0)
- ✅ Secure backend endpoint (JWT authenticated)
- ✅ Database update (balance + transaction record)
- ✅ Success feedback to user
- ✅ Error handling and display
- ✅ Transaction audit trail
- ✅ Loading states during processing
- ✅ Return to wallet page on success

---

## 🐛 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "User not authenticated" | Invalid/missing JWT | Ensure user is logged in |
| "Please enter a valid amount" | Amount ≤ 0 or not a number | Enter positive number > 0 |
| "Failed to top-up wallet: 500" | Server error | Check backend logs |
| "Error topping up wallet: Network error" | Connection failed | Check API URL in AppEnv |
| Balance doesn't update | Wallet not found in DB | Run wallet initialization on user signup |

---

## 📝 Notes for Developers

1. **Demo Mode:** Current implementation shows "(Demo Mode)" in messages
   - Replace with actual Stripe processing when ready

2. **Transaction Reference:** Uses timestamp-based ID for demo
   - Replace with Stripe payment ID in production

3. **No Payment Processing:** Demo mode adds funds immediately
   - Stripe version should verify payment before adding funds

4. **Testing Recommendations:**
   - Test with amount = 0 (should fail)
   - Test with negative amount (should fail)
   - Test with empty amount (should fail)
   - Test with network disconnected (should show error)
   - Test rapid clicks (should be prevented by _isProcessing flag)

---

## ✨ Summary

**Current Implementation:** ✅ Fully Functional Demo
- Complete end-to-end wallet top-up flow
- Database persistence
- Transaction logging
- Error handling
- User feedback

**Ready for Stripe Integration:** Yes
- Backend structure supports payment processing
- Frontend prepared for payment sheet
- Database schema ready for real payment data

**Next Steps:**
1. Add Stripe Secret Key to `.env`
2. Implement Stripe payment sheet in Flutter
3. Add payment verification in backend
4. Update transaction description to show Stripe charge ID
5. Add webhook handling for payment confirmations
