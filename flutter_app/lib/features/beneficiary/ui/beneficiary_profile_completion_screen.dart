import 'package:kindora/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../repositories/supabase_repositories.dart';

class BeneficiaryProfileCompletionScreen extends ConsumerStatefulWidget {
  const BeneficiaryProfileCompletionScreen({super.key});

  @override
  ConsumerState<BeneficiaryProfileCompletionScreen> createState() =>
      _BeneficiaryProfileCompletionScreenState();
}

class _BeneficiaryProfileCompletionScreenState
    extends ConsumerState<BeneficiaryProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  late TextEditingController _fullNameController;
  late TextEditingController _nicController;
  late TextEditingController _addressController;
  late TextEditingController _bankAccountHolderNameController;
  late TextEditingController _bankAccountNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankCodeController;

  final Color primaryColor = AppColors.primaryBlue;
  final Color accentColor = const Color(0xFFFF751F);

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _nicController = TextEditingController();
    _addressController = TextEditingController();
    _bankAccountHolderNameController = TextEditingController();
    _bankAccountNumberController = TextEditingController();
    _bankNameController = TextEditingController();
    _bankCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicController.dispose();
    _addressController.dispose();
    _bankAccountHolderNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankNameController.dispose();
    _bankCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      // Get Supabase user ID from Firebase UID
      final supabase = Supabase.instance.client;
      final userResponse = await supabase
          .from('users')
          .select('id')
          .eq('firebase_uid', firebaseUser.uid)
          .maybeSingle();

      if (userResponse == null) {
        throw Exception('User not found in Supabase');
      }

      final supabaseUserId = userResponse['id'] as String;

      final repository = BeneficiaryDetailsRepository();
      await repository.createBeneficiaryDetails(
        userId: supabaseUserId,
        fullName: _fullNameController.text.trim(),
        nic: _nicController.text.trim(),
        address: _addressController.text.trim(),
        bankAccountHolderName: _bankAccountHolderNameController.text.trim(),
        bankAccountNumber: _bankAccountNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        bankCode: _bankCodeController.text.trim(),
      );

      print('[BeneficiaryProfileCompletion] Profile created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed successfully!'),
            backgroundColor: AppColors.primaryBlue,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait 1 second to ensure Supabase sync before navigating
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          print('[BeneficiaryProfileCompletion] Navigating to dashboard');
          // Navigate to beneficiary dashboard
          context.go('/beneficiary/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Step indicator
                Text(
                  _currentStep == 0
                      ? 'Step 1: Personal Details'
                      : 'Step 2: Bank Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: _currentStep == 0
                        ? _buildPersonalDetailsStep()
                        : _buildBankDetailsStep(),
                  ),
                ),

                const SizedBox(height: 32),

                // Navigation buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _currentStep--);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_currentStep == 0) {
                                  // Validate and go to next step
                                  if (_validatePersonalDetails()) {
                                    setState(() => _currentStep++);
                                  }
                                } else {
                                  // Submit profile
                                  _submitProfile();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                _currentStep == 0 ? 'Next' : 'Complete Profile',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPersonalDetailsStep() {
    return [
      // Full Name
      TextFormField(
        controller: _fullNameController,
        decoration: InputDecoration(
          labelText: 'Full Name *',
          hintText: 'Enter your full name',
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Full name is required';
          }
          if (value!.length < 3) {
            return 'Full name must be at least 3 characters';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // NIC
      TextFormField(
        controller: _nicController,
        decoration: InputDecoration(
          labelText: 'NIC (National ID) *',
          hintText: 'Enter your NIC number',
          prefixIcon: const Icon(Icons.credit_card),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'NIC is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // Address
      TextFormField(
        controller: _addressController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Address *',
          hintText: 'Enter your full address',
          prefixIcon: const Icon(Icons.location_on),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Address is required';
          }
          if (value!.length < 10) {
            return 'Please provide a complete address';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildBankDetailsStep() {
    return [
      // Bank Name
      TextFormField(
        controller: _bankNameController,
        decoration: InputDecoration(
          labelText: 'Bank Name *',
          hintText: 'Enter your bank name',
          prefixIcon: const Icon(Icons.account_balance),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Bank name is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // Bank Code
      TextFormField(
        controller: _bankCodeController,
        decoration: InputDecoration(
          labelText: 'Bank Code *',
          hintText: 'Enter bank code',
          prefixIcon: const Icon(Icons.numbers),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Bank code is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // Account Holder Name
      TextFormField(
        controller: _bankAccountHolderNameController,
        decoration: InputDecoration(
          labelText: 'Account Holder Name *',
          hintText: 'Name on bank account',
          prefixIcon: const Icon(Icons.person_outline),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Account holder name is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // Account Number
      TextFormField(
        controller: _bankAccountNumberController,
        decoration: InputDecoration(
          labelText: 'Account Number *',
          hintText: 'Enter your account number',
          prefixIcon: const Icon(Icons.numbers),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Account number is required';
          }
          return null;
        },
      ),

      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your bank details are secure and will only be used to transfer funds from donations.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  bool _validatePersonalDetails() {
    if (_fullNameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_nicController.text.trim().isEmpty) {
      _showError('Please enter your NIC');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter your address');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
