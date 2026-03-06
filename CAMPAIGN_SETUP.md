# Campaign Pages Integration Guide

## Overview
The campaign feature has been successfully integrated into the Kindora platform. This includes campaign listing, viewing, and creation functionality.

## Frontend Features (Flutter)

### 1. Campaign Home Page (`campaign_home_page.dart`)
- **Route**: `/campaigns`
- **Features**:
  - View all campaigns with tabs (All, Ongoing, Success)
  - Campaign cards showing:
    - Campaign title
    - Raised amount
    - Progress bar towards target
    - Support button
    - Edit and share functionality
  - Floating action button to start new campaign
  - Uses Material Design 3 with custom colors
    - Primary: #0C0C79 (Dark Blue)
    - Accent: #FF751F (Orange)

### 2. Start Campaign Page (`start_campaign_page.dart`)
- **Route**: `/start-campaign`
- **Features**:
  - Campaign creation form with fields:
    - Title (required, min 3 chars)
    - Campaigner Name (required)
    - Campaign End Date (date picker)
    - Main Category (Charity/Campaign/Donation)
    - Campaign Type (Organization/Personal)
    - Target Amount (with currency selection: LKR/USD)
  - Form validation on all required fields
  - Cancel and Create Campaign buttons
  - Success feedback via SnackBar

## Backend APIs

### Campaign Endpoints
All endpoints are prefixed with `/api/campaigns`

#### GET `/api/campaigns`
- **Description**: Fetch all campaigns with filters
- **Query Parameters**:
  - `page`: Page number (default: 1)
  - `limit`: Items per page (default: 20, max: 100)
  - `status`: Filter by campaign status (optional)
  - `category`: Filter by category (optional)
  - `charityId`: Filter by charity (optional)
  - `search`: Search by title (optional)
- **Response**: Paginated list of campaigns

#### GET `/api/campaigns/:campaignId`
- **Description**: Get detailed campaign information
- **Response**: Campaign details with beneficiaries and recent donations

#### POST `/api/campaigns` (Protected)
- **Description**: Create new campaign
- **Body**:
  ```json
  {
    "title": "string (required, 3-255 chars)",
    "description": "string (required, min 10 chars)",
    "category": "string (required)",
    "target_amount": "number (required)",
    "beneficiary_details": "string (optional)",
    "beneficiary_location": "string (optional)",
    "image_url": "string (optional, valid URI)",
    "gallery_urls": ["string (optional, valid URIs)"],
    "end_date": "date (optional)"
  }
  ```

#### PUT `/api/campaigns/:campaignId` (Protected)
- **Description**: Update existing campaign
- **Body**: Any fields from POST body

#### GET `/api/campaigns/:campaignId/progress`
- **Description**: Get campaign progress
- **Response**:
  ```json
  {
    "target_amount": "number",
    "current_amount": "number",
    "progress": "percentage",
    "daysLeft": "number"
  }
  ```

#### GET `/api/campaigns/user/recommended` (Protected)
- **Description**: Get recommended campaigns for user
- **Query Parameters**:
  - `limit`: Number of campaigns (default: 10, max: 50)
- **Response**: Array of recommended campaigns

## Database Structure

The campaigns table includes:
- `campaign_id`: UUID primary key
- `charity_id`: Foreign key to charities table
- `title`: Campaign title
- `description`: Detailed description
- `category`: Campaign category
- `target_amount`: Fundraising goal
- `current_amount`: Amount raised so far
- `status`: 'active' or 'inactive'
- `beneficiary_details`: Information about beneficiaries
- `beneficiary_location`: Location of beneficiaries
- `image_url`: Campaign hero image
- `gallery_urls`: Array of additional images
- `end_date`: Campaign deadline
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

## Navigation

### How to Access Campaign Pages

From any screen in the app:

```dart
// Navigate to campaign listing
Navigator.of(context).pushNamed('/campaigns');

// Navigate to create campaign
Navigator.of(context).pushNamed('/start-campaign');

// Or using direct navigation
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const CampaignHomePage(),
));
```

### Integration Points

1. **In Home Screen**: Add button to navigate to `/campaigns`
   ```dart
   ElevatedButton(
     onPressed: () => Navigator.of(context).pushNamed('/campaigns'),
     child: const Text('Support a Campaign'),
   ),
   ElevatedButton(
     onPressed: () => Navigator.of(context).pushNamed('/start-campaign'),
     child: const Text('Start a Campaign'),
   ),
   ```

2. **In App Navigation Menu**: Add menu items for campaigns

## API Client Integration

To connect Flutter app to backend:

```dart
// Example: Fetch campaigns
Future<void> fetchCampaigns() async {
  final response = await http.get(
    Uri.parse('https://api.kindora.com/api/campaigns?page=1&limit=20'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Handle campaign data
  }
}

// Example: Create campaign
Future<void> createCampaign({
  required String title,
  required String description,
  required String category,
  required double targetAmount,
}) async {
  final response = await http.post(
    Uri.parse('https://api.kindora.com/api/campaigns'),
    headers: {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'title': title,
      'description': description,
      'category': category,
      'target_amount': targetAmount,
    }),
  );
  
  if (response.statusCode == 201) {
    // Campaign created successfully
  }
}
```

## Notes

- **Payment Integration**: Payment/donation functionality is NOT included in this integration. The "Support Campaign" button currently shows a placeholder message.
- **Image Uploads**: Current implementation uses image URLs. Update `start_campaign_page.dart` to support image selection/upload.
- **Form Submission**: The form currently shows a success message but doesn't actually submit. Connect it to backend API in the `Create Campaign` button handler.
- **Authentication**: Campaign creation and updates require user authentication (protected routes).

## Next Steps

1. Connect the form submission to the backend API
2. Implement image upload functionality
3. Add real campaign listing from backend
4. Integrate with payment system for donations
5. Add campaign editing functionality
6. Implement notifications for campaign status updates
