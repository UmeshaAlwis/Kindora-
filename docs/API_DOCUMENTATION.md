# Kindora Backend API Documentation

## Base URL
```
Development: http://localhost:5000/api
Production: https://api.kindora.com/api
```

## Authentication

All protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

## API Endpoints

### Authentication Endpoints

#### 1. Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "full_name": "John Doe",
  "role": "donor",
  "phone_number": "+94701234567"
}
```

**Response (201)**:
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "full_name": "John Doe",
      "role": "donor",
      "created_at": "2024-01-15T10:30:00Z"
    }
  },
  "message": "User registered successfully"
}
```

#### 2. Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200)**:
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "full_name": "John Doe",
      "role": "donor"
    }
  },
  "message": "Login successful"
}
```

#### 3. Get Current User
```http
GET /auth/me
Authorization: Bearer <access_token>
```

**Response (200)**:
```json
{
  "success": true,
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "full_name": "John Doe",
    "role": "donor",
    "profile_image_url": "https://...",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### 4. Refresh Token
```http
POST /auth/refresh-token
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

#### 5. Request Password Reset
```http
POST /auth/request-password-reset
Content-Type: application/json

{
  "email": "user@example.com"
}
```

#### 6. Reset Password
```http
POST /auth/reset-password
Content-Type: application/json

{
  "token": "reset-token",
  "password": "NewPassword123!"
}
```

### Campaign Endpoints

#### 1. Get All Campaigns
```http
GET /campaigns?page=1&limit=20&status=active&category=education
Authorization: Bearer <access_token>
```

**Parameters**:
- `page` (integer): Page number (default: 1)
- `limit` (integer): Items per page (default: 20)
- `status` (string): Filter by status (active, completed, closed, paused)
- `category` (string): Filter by category

**Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "campaign_id": "campaign-id",
      "title": "Build School Library",
      "description": "Help us build a library for rural schools",
      "target_amount": 5000,
      "current_amount": 2500,
      "progress": 50,
      "donor_count": 45,
      "status": "active",
      "charity_id": "charity-id",
      "image_url": "https://...",
      "start_date": "2024-01-15T10:30:00Z",
      "end_date": "2024-03-15T10:30:00Z"
    }
  ],
  "total": 100,
  "page": 1,
  "limit": 20,
  "pages": 5
}
```

#### 2. Get Campaign Details
```http
GET /campaigns/:campaignId
Authorization: Bearer <access_token>
```

#### 3. Create Campaign (Charity Only)
```http
POST /campaigns
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "title": "Build School Library",
  "description": "Help us build a library for rural schools",
  "category": "education",
  "target_amount": 5000,
  "beneficiary_details": "50 students in rural area",
  "beneficiary_location": "Anuradhapura District",
  "image_url": "https://...",
  "gallery_urls": ["https://..."],
  "end_date": "2024-03-15"
}
```

### Donation Endpoints

#### 1. Make a Donation
```http
POST /donations
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "campaign_id": "campaign-id",
  "amount": 100,
  "payment_method": "card",
  "donation_type": "one-time",
  "message": "Love your work!",
  "is_anonymous": false
}
```

**Response (201)**:
```json
{
  "success": true,
  "data": {
    "donation_id": "donation-id",
    "campaign_id": "campaign-id",
    "amount": 100,
    "status": "pending",
    "payment_url": "https://payhere.lk/pay/...",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### 2. Get Donation History
```http
GET /donations?page=1&limit=20
Authorization: Bearer <access_token>
```

#### 3. Set Up Recurring Donation
```http
POST /donations/recurring
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "campaign_id": "campaign-id",
  "amount": 50,
  "frequency": "monthly",
  "start_date": "2024-02-01",
  "end_date": "2024-12-31"
}
```

### Charity Endpoints

#### 1. Get Charity Profile
```http
GET /charities/:charityId
Authorization: Bearer <access_token>
```

#### 2. Register as Charity
```http
POST /charities
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Help Foundation",
  "description": "Description of your organization",
  "category": "education",
  "registration_number": "REG123456",
  "contact_info": "+94701234567",
  "website_url": "https://help.org",
  "documents_url": ["https://...document.pdf"]
}
```

#### 3. Update Charity Profile (Charity Only)
```http
PUT /charities/:charityId
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Messaging Endpoints

#### 1. Send Message
```http
POST /messages
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "receiver_id": "user-id",
  "campaign_id": "campaign-id",
  "content": "Thank you for the donation!",
  "attachment_url": "https://..."
}
```

#### 2. Get Conversations
```http
GET /messages/conversations
Authorization: Bearer <access_token>
```

#### 3. Get Message History
```http
GET /messages/:conversationId?limit=50
Authorization: Bearer <access_token>
```

### Gamification Endpoints

#### 1. Get User Stats
```http
GET /gamification/:userId
Authorization: Bearer <access_token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "user_id": "user-id",
    "total_points": 2500,
    "donor_level": "gold",
    "badge_ids": ["first_donation", "100_donors"],
    "total_donations": 15,
    "streak_days": 30,
    "achievements": [
      {
        "id": "first_donation",
        "name": "First Step",
        "description": "Made your first donation",
        "earned_at": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

#### 2. Get Leaderboard
```http
GET /gamification/leaderboard?limit=100
Authorization: Bearer <access_token>
```

### Admin Endpoints

#### 1. Get All Users
```http
GET /admin/users?page=1&limit=20&role=donor
Authorization: Bearer <admin_token>
```

#### 2. Verify Charity
```http
POST /admin/charities/:charityId/verify
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "verified": true,
  "notes": "All documents verified"
}
```

#### 3. Get Analytics
```http
GET /admin/analytics?startDate=2024-01-01&endDate=2024-02-01
Authorization: Bearer <admin_token>
```

#### 4. Review Scam Report
```http
POST /admin/scam-reports/:reportId/review
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "verified": true,
  "notes": "Confirmed fraudulent activity",
  "action": "close_campaign"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Validation error message"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Unauthorized - Token invalid or expired"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "Access denied"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Internal server error"
}
```

## Rate Limiting

API endpoints are rate limited to:
- 100 requests per 15 minutes per IP address
- Response headers include rate limit info:
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 95`
  - `X-RateLimit-Reset: 1642354200`

## Pagination

Paginated responses include:
- `total`: Total number of items
- `page`: Current page number
- `limit`: Items per page
- `pages`: Total number of pages

## Date Format

All timestamps use ISO 8601 format: `YYYY-MM-DDTHH:mm:ssZ`

## Status Codes

- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `204 No Content`: Successful request with no response body
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

For more detailed information, see the backend code documentation.
