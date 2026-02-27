import 'package:flutter/material.dart';

void main() {
  runApp(const KindoraApp());
}

class KindoraApp extends StatelessWidget {
  const KindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kindora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B21A8)),
      ),
      home: const MainScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

enum DonationFrequency { daily, weekly, monthly }

extension DonationFrequencyExt on DonationFrequency {
  String get label {
    switch (this) {
      case DonationFrequency.daily:
        return 'Daily';
      case DonationFrequency.weekly:
        return 'Weekly';
      case DonationFrequency.monthly:
        return 'Monthly';
    }
  }

  String get description {
    switch (this) {
      case DonationFrequency.daily:
        return 'Charged every day';
      case DonationFrequency.weekly:
        return 'Charged every week';
      case DonationFrequency.monthly:
        return 'Charged every month';
    }
  }
}

class RecurringDonation {
  final String id;
  final String charityName;
  final String charityCategory;
  final String charityIcon;
  final double amount;
  final DonationFrequency frequency;
  final DateTime nextPaymentDate;
  bool isActive;

  RecurringDonation({
    required this.id,
    required this.charityName,
    required this.charityCategory,
    required this.charityIcon,
    required this.amount,
    required this.frequency,
    required this.nextPaymentDate,
    this.isActive = true,
  });
}

class Charity {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String description;

  const Charity({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
  });
}

final List<RecurringDonation> mockRecurringDonations = [
  RecurringDonation(
    id: '1',
    charityName: 'Red Cross',
    charityCategory: 'Disaster Relief',
    charityIcon: '🏥',
    amount: 50,
    frequency: DonationFrequency.monthly,
    nextPaymentDate: DateTime.now().add(const Duration(days: 7)),
  ),
  RecurringDonation(
    id: '2',
    charityName: 'World Wildlife Fund',
    charityCategory: 'Environment',
    charityIcon: '🌍',
    amount: 25,
    frequency: DonationFrequency.weekly,
    nextPaymentDate: DateTime.now().add(const Duration(days: 3)),
  ),
  RecurringDonation(
    id: '3',
    charityName: 'Local Food Bank',
    charityCategory: 'Hunger Relief',
    charityIcon: '🍱',
    amount: 15,
    frequency: DonationFrequency.monthly,
    nextPaymentDate: DateTime.now().add(const Duration(days: 14)),
  ),
];

final List<Charity> mockCharities = [
  const Charity(
    id: '1',
    name: 'Red Cross',
    category: 'Disaster Relief',
    icon: '🏥',
    description: 'Providing emergency aid and disaster relief',
  ),
  const Charity(
    id: '2',
    name: 'World Wildlife Fund',
    category: 'Environment',
    icon: '🌍',
    description: 'Protecting endangered wildlife and habitats',
  ),
  const Charity(
    id: '3',
    name: 'Local Food Bank',
    category: 'Hunger Relief',
    icon: '🍱',
    description: 'Fighting hunger in our community',
  ),
  const Charity(
    id: '4',
    name: 'Education Initiative',
    category: 'Education',
    icon: '📚',
    description: 'Providing education to underprivileged children',
  ),
  const Charity(
    id: '5',
    name: 'Mental Health Support',
    category: 'Health',
    icon: '🧠',
    description: 'Supporting mental health and wellbeing programs',
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// RECURRING DONATION SCREENS
// ═══════════════════════════════════════════════════════════════════════════════

class RecurringDonationScreen extends StatefulWidget {
  const RecurringDonationScreen({super.key});

  @override
  State<RecurringDonationScreen> createState() =>
      _RecurringDonationScreenState();
}

class _RecurringDonationScreenState extends State<RecurringDonationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<RecurringDonation> _donations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _donations = List.from(mockRecurringDonations);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate monthly commitment
    double monthlyTotal = 0;
    for (var donation in _donations) {
      if (donation.isActive) {
        switch (donation.frequency) {
          case DonationFrequency.daily:
            monthlyTotal += donation.amount * 30;
            break;
          case DonationFrequency.weekly:
            monthlyTotal += donation.amount * 4.3;
            break;
          case DonationFrequency.monthly:
            monthlyTotal += donation.amount;
            break;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF4),
        elevation: 0,
        title: const Text(
          'Recurring Donations',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Monthly Commitment Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Commitment',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${monthlyTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B21A8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF6B21A8),
            unselectedLabelColor: const Color(0xFF999999),
            indicatorColor: const Color(0xFF6B21A8),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Add New'),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ActiveDonationsTab(
                  donations: _donations,
                  onToggle: (id, value) {
                    setState(() {
                      final index = _donations.indexWhere((d) => d.id == id);
                      if (index >= 0) {
                        _donations[index].isActive = value;
                      }
                    });
                  },
                  onEdit: (donation) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditRecurringDonationScreen(donation: donation),
                      ),
                    ).then((result) {
                      if (result != null) {
                        setState(() {
                          final index = _donations.indexWhere((d) => d.id == result.id);
                          if (index >= 0) {
                            _donations[index] = result;
                          }
                        });
                      }
                    });
                  },
                  onCancel: (id) {
                    setState(() {
                      _donations.removeWhere((d) => d.id == id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Donation cancelled'),
                        backgroundColor: Color(0xFF6B21A8),
                      ),
                    );
                  },
                ),
                _AddDonationTab(
                  onAdd: (charityId, amount, frequency) {
                    final charity = mockCharities.firstWhere(
                      (c) => c.id == charityId,
                      orElse: () => mockCharities[0],
                    );
                    setState(() {
                      _donations.add(
                        RecurringDonation(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          charityName: charity.name,
                          charityCategory: charity.category,
                          charityIcon: charity.icon,
                          amount: amount,
                          frequency: frequency,
                          nextPaymentDate:
                              DateTime.now().add(const Duration(days: 1)),
                        ),
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added donation to ${charity.name}'),
                        backgroundColor: const Color(0xFF6B21A8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveDonationsTab extends StatelessWidget {
  final List<RecurringDonation> donations;
  final Function(String, bool) onToggle;
  final Function(RecurringDonation) onEdit;
  final Function(String) onCancel;

  const _ActiveDonationsTab({
    required this.donations,
    required this.onToggle,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final donation = donations[index];
        return _DonationCard(
          donation: donation,
          onToggle: (value) => onToggle(donation.id, value),
          onEdit: () => onEdit(donation),
          onCancel: () => onCancel(donation.id),
        );
      },
    );
  }
}

class _DonationCard extends StatelessWidget {
  final RecurringDonation donation;
  final Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _DonationCard({
    required this.donation,
    required this.onToggle,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // Charity Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        donation.charityIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Charity Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.charityName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _InfoChip(
                              label: donation.charityCategory,
                              backgroundColor: const Color(0xFFF3E8FF),
                              textColor: const Color(0xFF6B21A8),
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              label: donation.frequency.label,
                              backgroundColor: const Color(0xFFFEF3C7),
                              textColor: const Color(0xFF92400E),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Toggle
                  Switch(
                    value: donation.isActive,
                    onChanged: onToggle,
                    activeColor: const Color(0xFF6B21A8),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${donation.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B21A8),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onEdit,
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF6B21A8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddDonationTab extends StatefulWidget {
  final Function(String, double, DonationFrequency) onAdd;

  const _AddDonationTab({required this.onAdd});

  @override
  State<_AddDonationTab> createState() => _AddDonationTabState();
}

class _AddDonationTabState extends State<_AddDonationTab> {
  late TextEditingController _amountController;
  String? _selectedCharityId;
  DonationFrequency _selectedFrequency = DonationFrequency.monthly;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _selectedCharityId = mockCharities[0].id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Charity Selection
            const Text(
              'Select Charity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCharityId,
              items: mockCharities
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Text(
                            c.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCharityId = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              validator: (value) => value == null ? 'Please select a charity' : null,
            ),
            const SizedBox(height: 24),
            // Amount Input
            const Text(
              'Donation Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Enter amount',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                prefixText: '\$ ',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value!) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Frequency Selection
            const Text(
              'Donation Frequency',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: DonationFrequency.values
                  .map(
                    (frequency) => ChoiceChip(
                      label: Text(frequency.label),
                      selected: _selectedFrequency == frequency,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFrequency = frequency);
                        }
                      },
                      selectedColor: const Color(0xFF6B21A8),
                      labelStyle: TextStyle(
                        color: _selectedFrequency == frequency
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: _selectedFrequency == frequency
                            ? const Color(0xFF6B21A8)
                            : Colors.grey[300]!,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _selectedCharityId!,
                      double.parse(_amountController.text),
                      _selectedFrequency,
                    );
                    _amountController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B21A8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Create Recurring Donation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class EditRecurringDonationScreen extends StatefulWidget {
  final RecurringDonation donation;

  const EditRecurringDonationScreen({
    super.key,
    required this.donation,
  });

  @override
  State<EditRecurringDonationScreen> createState() =>
      _EditRecurringDonationScreenState();
}

class _EditRecurringDonationScreenState
    extends State<EditRecurringDonationScreen> {
  late TextEditingController _amountController;
  late DonationFrequency _selectedFrequency;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.donation.amount.toString(),
    );
    _selectedFrequency = widget.donation.frequency;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Donation',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Charity Info (Read-only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.donation.charityIcon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.donation.charityName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.donation.charityCategory,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Amount Input
              const Text(
                'Donation Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter amount',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixText: '\$ ',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Frequency Selection
              const Text(
                'Donation Frequency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: DonationFrequency.values
                    .map(
                      (frequency) => ChoiceChip(
                        label: Text(frequency.label),
                        selected: _selectedFrequency == frequency,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFrequency = frequency);
                          }
                        },
                        selectedColor: const Color(0xFF6B21A8),
                        labelStyle: TextStyle(
                          color: _selectedFrequency == frequency
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _selectedFrequency == frequency
                              ? const Color(0xFF6B21A8)
                              : Colors.grey[300]!,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final updated = RecurringDonation(
                        id: widget.donation.id,
                        charityName: widget.donation.charityName,
                        charityCategory: widget.donation.charityCategory,
                        charityIcon: widget.donation.charityIcon,
                        amount: double.parse(_amountController.text),
                        frequency: _selectedFrequency,
                        nextPaymentDate: widget.donation.nextPaymentDate,
                        isActive: widget.donation.isActive,
                      );
                      Navigator.pop(context, updated);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B21A8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DONATION DASHBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class DonationDashboardScreen extends StatelessWidget {
  const DonationDashboardScreen({super.key});

  // Mock donation history data
  static const List<Map<String, dynamic>> _donationHistory = [
    {
      'charity': 'Red Cross',
      'icon': '🏥',
      'amount': 50,
      'date': 'Feb 20, 2026',
      'status': 'Success',
    },
    {
      'charity': 'World Wildlife Fund',
      'icon': '🌍',
      'amount': 25,
      'date': 'Feb 13, 2026',
      'status': 'Success',
    },
    {
      'charity': 'Local Food Bank',
      'icon': '🍱',
      'amount': 15,
      'date': 'Feb 6, 2026',
      'status': 'Success',
    },
    {
      'charity': 'Education Initiative',
      'icon': '📚',
      'amount': 75,
      'date': 'Jan 30, 2026',
      'status': 'Success',
    },
    {
      'charity': 'Mental Health Support',
      'icon': '🧠',
      'amount': 40,
      'date': 'Jan 23, 2026',
      'status': 'Success',
    },
    {
      'charity': 'Red Cross',
      'icon': '🏥',
      'amount': 50,
      'date': 'Jan 16, 2026',
      'status': 'Success',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF4),
        elevation: 0,
        title: const Text(
          'Donation History',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Donated',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '\$290',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B21A8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Donations',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '6',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Charities',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '5',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Avg Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$48',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // History List Title
            const Text(
              'Recent Donations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            // History Tiles
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _donationHistory.length,
              itemBuilder: (context, index) {
                final donation = _donationHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Charity Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                donation['icon'],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Charity Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation['charity'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  donation['date'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Amount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${donation['amount']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Success',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREENS
// ═══════════════════════════════════════════════════════════════════════════════

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 4;

  final List<Widget> _pages = [
    const PlaceholderPage(label: 'Home'),
    const PlaceholderPage(label: 'Feed'),
    const PlaceholderPage(label: 'Messages'),
    const PlaceholderPage(label: 'Merch'),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6B21A8),
        unselectedItemColor: const Color(0xFF999999),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Merch'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle app exit
              },
              child: const Text('Exit', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF4),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B21A8),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: Text(
                          '👤',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'john@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Menu Items
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.favorite,
                      label: 'Regular Donation',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RecurringDonationScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                    _buildMenuItem(
                      icon: Icons.history,
                      label: 'Donation History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DonationDashboardScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                    _buildMenuItem(
                      icon: Icons.card_giftcard,
                      label: 'Rewards',
                      onTap: () {},
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                    _buildMenuItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            // Settings Toggles
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildToggleItem(
                      icon: Icons.notifications,
                      label: 'Notifications',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() =>
                            _notificationsEnabled = value);
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                    _buildToggleItem(
                      icon: Icons.dark_mode,
                      label: 'Dark Mode',
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() => _darkModeEnabled = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Exit Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showExitDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Exit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6B21A8),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF999999),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6B21A8),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6B21A8),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PLACEHOLDER
// ═══════════════════════════════════════════════════════════════════════════════

class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B21A8))),
    );
  }
}
