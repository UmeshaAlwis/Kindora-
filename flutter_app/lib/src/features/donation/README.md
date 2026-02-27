# Donation Dashboard Feature

A comprehensive Flutter donation dashboard screen for the Kindora charity app.

## Features

- **Summary Cards**: Display total amount donated, campaigns supported, and kind points earned
- **Donation History**: View past donations with status badges and receipt download functionality
- **Recurring Donations**: Manage active recurring donations with cancel option
- **Impact Chart**: Pie chart visualization of donation distribution by category
- **Pull-to-Refresh**: Refresh all data with a simple pull gesture
- **Error Handling**: Comprehensive error messages and retry options
- **Loading States**: Shimmer and loading indicators for better UX
- **Mock Data**: Built-in mock data for testing without backend

## Tech Stack

- **State Management**: Provider
- **HTTP Calls**: http package with Bearer token authentication
- **Charts**: fl_chart for pie chart visualization
- **Firebase Auth**: Integration-ready for token management

## Installation

### 1. Add Dependencies

Make sure `pubspec.yaml` includes:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  http: ^1.1.0
  fl_chart: ^0.65.0
  equatable: ^2.0.0
  firebase_auth: ^4.7.0
```

Run `flutter pub get`

### 2. Setup the Provider

In your `main.dart`, add the donation provider:

```dart
import 'package:kindora/src/features/donation/models/donation_provider.dart';
import 'package:kindora/src/features/donation/repositories/donation_repository.dart';
import 'package:kindora/src/features/donation/screens/donation_dashboard_screen.dart';

void main() async {
  // Initialize Firebase, etc.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => DonationDashboardProvider(
              repository: DonationRepository(
                baseUrl: 'your_api_base_url', // e.g., 'https://api.example.com'
                getToken: () {
                  // Get Firebase token
                  return FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
                },
              ),
            ),
          ),
        ],
        child: Consumer<DonationDashboardProvider>(
          builder: (context, provider, _) {
            return const DonationDashboardScreen();
          },
        ),
      ),
    );
  }
}
```

### 3. Using Mock Data for Testing

To test with mock data without a backend:

```dart
import 'package:kindora/src/features/donation/models/mock_data.dart';
import 'package:kindora/src/features/donation/models/donation_provider.dart';

class MockDonationRepository extends DonationRepository {
  MockDonationRepository() 
    : super(
        baseUrl: '', 
        getToken: () => 'mock-token'
      );

  @override
  Future<DonationSummary> fetchDonationSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDonationData.mockSummary;
  }

  @override
  Future<List<Donation>> fetchDonationHistory({int page = 1, int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDonationData.mockDonationHistory;
  }

  @override
  Future<List<RecurringDonation>> fetchRecurringDonations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDonationData.mockRecurringDonations;
  }

  @override
  Future<List<CategoryBreakdown>> fetchCategoryBreakdown() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDonationData.mockCategoryBreakdown;
  }

  @override
  Future<void> cancelRecurringDonation(String donationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<String> downloadReceipt(String donationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'Receipt downloaded';
  }
}
```

## API Endpoints

The dashboard expects the following API endpoints:

### GET /api/analytics/summary
Returns donation summary and category breakdown.

**Response:**
```json
{
  "totalAmountDonated": 4500,
  "totalCampaignsSupported": 8,
  "kindPointsEarned": 200,
  "breakdown": [
    {
      "category": "Education",
      "amount": 1200,
      "count": 4
    },
    ...
  ]
}
```

### GET /api/donations/history?page=1&limit=10
Returns paginated donation history.

**Response:**
```json
[
  {
    "id": "1",
    "charityName": "Education First",
    "charityId": "ef-001",
    "amount": 850,
    "date": "2024-04-20T10:00:00Z",
    "status": "success",
    "receiptUrl": "https://...",
    "receiptId": "receipt-001",
    "category": "Education"
  },
  ...
]
```

### GET /api/donations/recurring
Returns active recurring donations.

**Response:**
```json
[
  {
    "id": "rec-1",
    "charityName": "Children's Hope",
    "charityId": "chf-001",
    "amountPerCycle": 500,
    "frequency": "monthly",
    "startDate": "2024-01-15T00:00:00Z",
    "nextDueDate": "2024-06-15T00:00:00Z",
    "active": true,
    "category": "Children"
  },
  ...
]
```

### POST /api/donations/recurring/{id}/cancel
Cancels a recurring donation. Returns 200 on success.

### GET /api/donations/{id}/receipt
Downloads a donation receipt. Returns the PDF file.

## Design

- **Primary Color**: Purple (#6B21A8)
- **Secondary Colors**:
  - Blue: #1E40AF
  - Amber: #92400E
- **All cards have**:
  - Rounded corners (12px)
  - Subtle shadows
  - Consistent padding (16px)

## File Structure

```
lib/src/features/donation/
├── models/
│   ├── donation_model.dart      # Data models
│   ├── donation_provider.dart   # State management
│   └── mock_data.dart           # Mock data for testing
├── repositories/
│   └── donation_repository.dart # API calls
├── screens/
│   └── donation_dashboard_screen.dart # Main screen
├── widgets/
│   └── donation_widgets.dart    # Reusable widgets
└── exports.dart                 # Barrel export
```

## Customization

### Change Colors

Edit the color codes in `donation_widgets.dart` and `donation_dashboard_screen.dart`:

```dart
const Color(0xFF6B21A8) // Purple
const Color(0xFFF3E8FF) // Light purple
```

### Add More Categories

Update `MockDonationData` or your API to include additional categories in `categoryBreakdown`.

### Adjust Chart Size

In `ImpactChart`, modify the `height` and `radius` values:

```dart
child: SizedBox(
  height: 200, // Change this
  child: PieChart(
    PieChartData(
      sections: [...],
    ),
  ),
),
```

## Testing

### Test with Mock Data

```dart
// In main.dart
final mockRepo = MockDonationRepository();
const donationProvider = DonationDashboardProvider(repository: mockRepo);
```

### Test Pull-to-Refresh

Drag down on the screen to trigger a refresh of all data.

### Test Error State

Modify the repository to throw an exception to test error handling.

## Future Enhancements

- [ ] Graphical donation trends/analytics with line charts
- [ ] Filter donations by date range and category
- [ ] Export donation history to CSV/PDF
- [ ] Donation receipts with PDF generation
- [ ] Social sharing of donation milestones
- [ ] Donation certificates
- [ ] Push notifications for recurring donation reminders
- [ ] Comparison with other donors (leaderboard)

## Troubleshooting

### Charts not displaying
- Ensure fl_chart is properly installed: `flutter pub get`
- Check that the data list is not empty

### API calls failing
- Verify the base URL is correct
- Ensure Firebase token is being passed correctly
- Check network connectivity

### Provider not updating
- Make sure `notifyListeners()` is called after data updates
- Verify Consumer is wrapping the widget that needs updates

## License

Part of the Kindora Charity App project.
