import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation_provider.dart';
import '../models/donation_model.dart';
import '../widgets/donation_widgets.dart';

class DonationDashboardScreen extends StatefulWidget {
  const DonationDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DonationDashboardScreen> createState() =>
      _DonationDashboardScreenState();
}

class _DonationDashboardScreenState extends State<DonationDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonationDashboardProvider>().fetchDonationSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        title: const Text(
          'My Donations',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<DonationDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6B21A8),
                ),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDonations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadDonations();
              await Future.delayed(const Duration(seconds: 2));
            },
            color: const Color(0xFF6B21A8),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Section
                  if (provider.summary != null) ...[
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SummaryCard(
                            title: 'Total Donated',
                            value: '\$${provider.summary!.totalAmountDonated.toStringAsFixed(2)}',
                            icon: Icons.favorite,
                            backgroundColor: const Color(0xFFFEE2E2),
                            textColor: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          SummaryCard(
                            title: 'Campaigns',
                            value: '${provider.summary!.totalCampaignsSupported}',
                            icon: Icons.campaign,
                            backgroundColor: const Color(0xFFDEBFFF),
                            textColor: const Color(0xFF6B21A8),
                          ),
                          const SizedBox(width: 8),
                          SummaryCard(
                            title: 'Kind Points',
                            value: '${provider.summary!.kindPointsEarned}',
                            icon: Icons.star,
                            backgroundColor: const Color(0xFFDEF7EC),
                            textColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // Donation History Section
                  Text(
                    'Donation History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.donationHistory.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.favorite_border,
                      title: 'No Donations Yet',
                      message:
                          'Start making a difference by making your first donation',
                    )
                  else
                    Column(
                      children: provider.donationHistory.map((donation) {
                        return DonationHistoryCard(
                          donation: donation,
                          onDownloadReceipt: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Downloading receipt...'),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),
                  // Recurring Donations Section
                  if (provider.recurringDonations.isNotEmpty) ...[
                    Text(
                      'Recurring Donations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: provider.recurringDonations.map((recurring) {
                        return RecurringDonationCard(
                          donation: recurring,
                          onCancel: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cancelled recurring donation to ${recurring.charityName}',
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // Impact Chart Section
                  if (provider.categoryBreakdown.isNotEmpty) ...[
                    Text(
                      'Impact by Category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ImpactChart(
                      data: provider.categoryBreakdown,
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
