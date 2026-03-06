import 'package:flutter/material.dart';
import 'package:kindora/src/features/payment/presentation/widgets/payment_helper.dart';

class CharityListPage extends StatefulWidget {
  const CharityListPage({Key? key}) : super(key: key);

  @override
  State<CharityListPage> createState() => _CharityListPageState();
}

class _CharityListPageState extends State<CharityListPage> {
  final List<Map<String, dynamic>> charities = [
    {
      'id': '1',
      'name': 'Children Education Fund',
      'description': 'Providing quality education for underprivileged children',
      'image': '🎓',
      'raised': 45000,
      'goal': 100000,
    },
    {
      'id': '2',
      'name': 'Clean Water Initiative',
      'description': 'Building water wells in remote areas',
      'image': '💧',
      'raised': 78000,
      'goal': 150000,
    },
    {
      'id': '3',
      'name': 'Healthcare for All',
      'description': 'Free medical camps and health awareness',
      'image': '🏥',
      'raised': 62000,
      'goal': 120000,
    },
    {
      'id': '4',
      'name': 'Food Security Program',
      'description': 'Providing meals to homeless and needy',
      'image': '🍲',
      'raised': 35000,
      'goal': 80000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Featured Charities'),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: charities.length,
        itemBuilder: (context, index) {
          final charity = charities[index];
          final progress = charity['raised'] / charity['goal'];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with emoji and name
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            charity['image'],
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              charity['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              charity['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LKR ${charity['raised'].toString()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'of LKR ${charity['goal'].toString()}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green[600]!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% funded',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Donate button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _showDonationModal(context, charity),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Donate Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDonationModal(BuildContext context, Map<String, dynamic> charity) {
    PaymentHelper.showDonationModal(
      context: context,
      charityId: charity['id'],
      charityName: charity['name'],
      onDonationSelected: (donationData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanks for donating ${donationData['currency']}${donationData['amount'].toStringAsFixed(0)} to ${charity['name']}!',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        debugPrint('Donation Details: $donationData');
      },
    );
  }
}
