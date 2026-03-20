import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/supabase_models.dart';
import '../../../providers/supabase_providers.dart';
import '../../../repositories/supabase_repositories.dart';

class BeneficiaryProfileScreen extends ConsumerStatefulWidget {
  const BeneficiaryProfileScreen({super.key});

  @override
  ConsumerState<BeneficiaryProfileScreen> createState() =>
      _BeneficiaryProfileScreenState();
}

class _BeneficiaryProfileScreenState
    extends ConsumerState<BeneficiaryProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _fullNameController;
  late TextEditingController _nicController;
  late TextEditingController _addressController;
  late TextEditingController _bankAccountHolderNameController;
  late TextEditingController _bankAccountNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankCodeController;

  final Color primaryColor = const Color(0xFF0C0C79);
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

  void _loadBeneficiaryDetails(BeneficiaryDetails details) {
    _fullNameController.text = details.fullName;
    _nicController.text = details.nic;
    _addressController.text = details.address;
    _bankAccountHolderNameController.text = details.bankAccountHolderName;
    _bankAccountNumberController.text = details.bankAccountNumber;
    _bankNameController.text = details.bankName;
    _bankCodeController.text = details.bankCode;
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

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
      await repository.updateBeneficiaryDetails(
        userId: supabaseUserId,
        fullName: _fullNameController.text.trim(),
        nic: _nicController.text.trim(),
        address: _addressController.text.trim(),
        bankAccountHolderName: _bankAccountHolderNameController.text.trim(),
        bankAccountNumber: _bankAccountNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        bankCode: _bankCodeController.text.trim(),
      );

      // Refresh the provider
      ref.refresh(beneficiaryDetailsProvider(supabaseUserId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isEditing && user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing && user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? Center(
                child: Text(
                  'Please sign in',
                  style: TextStyle(color: primaryColor),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryColor,
                            primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              (() {
                                final name = user.displayName?.trim() ?? '';
                                if (name.isEmpty) return 'U';
                                return name[0].toUpperCase();
                              })(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.email ?? 'User',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile Details
                    _BeneficiaryDetailsContent(
                      userId: user.uid,
                      isEditing: _isEditing,
                      isSaving: _isSaving,
                      fullNameController: _fullNameController,
                      nicController: _nicController,
                      addressController: _addressController,
                      bankAccountHolderNameController:
                          _bankAccountHolderNameController,
                      bankAccountNumberController: _bankAccountNumberController,
                      bankNameController: _bankNameController,
                      bankCodeController: _bankCodeController,
                      primaryColor: primaryColor,
                      accentColor: accentColor,
                      onLoadDetails: _loadBeneficiaryDetails,
                      onSave: _saveProfile,
                      onCancel: () => setState(() => _isEditing = false),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BeneficiaryDetailsContent extends ConsumerWidget {
  final String userId;
  final bool isEditing;
  final bool isSaving;
  final TextEditingController fullNameController;
  final TextEditingController nicController;
  final TextEditingController addressController;
  final TextEditingController bankAccountHolderNameController;
  final TextEditingController bankAccountNumberController;
  final TextEditingController bankNameController;
  final TextEditingController bankCodeController;
  final Color primaryColor;
  final Color accentColor;
  final Function(BeneficiaryDetails) onLoadDetails;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _BeneficiaryDetailsContent({
    required this.userId,
    required this.isEditing,
    required this.isSaving,
    required this.fullNameController,
    required this.nicController,
    required this.addressController,
    required this.bankAccountHolderNameController,
    required this.bankAccountNumberController,
    required this.bankNameController,
    required this.bankCodeController,
    required this.primaryColor,
    required this.accentColor,
    required this.onLoadDetails,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(beneficiaryDetailsProvider(userId));

    return detailsAsync.when(
      data: (details) {
        if (details == null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Profile not completed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Load details into controllers if coming from network
        if (!isEditing && fullNameController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLoadDetails(details);
          });
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Details Section
              _buildSectionTitle('Personal Information', primaryColor),
              const SizedBox(height: 16),
              _buildDetailField(
                'Full Name',
                fullNameController,
                isEditing,
                Icons.person,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'NIC (National ID)',
                nicController,
                false, // Don't allow editing NIC
                Icons.credit_card,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Address',
                addressController,
                isEditing,
                Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Bank Details Section
              _buildSectionTitle('Bank Details', primaryColor),
              const SizedBox(height: 16),
              _buildDetailField(
                'Bank Name',
                bankNameController,
                isEditing,
                Icons.account_balance,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Bank Code',
                bankCodeController,
                isEditing,
                Icons.numbers,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Account Holder Name',
                bankAccountHolderNameController,
                isEditing,
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Account Number',
                bankAccountNumberController,
                isEditing,
                Icons.numbers,
              ),

              if (isEditing) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving ? null : onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Error loading profile: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(
    String label,
    TextEditingController controller,
    bool isEditing,
    IconData icon, {
    int maxLines = 1,
  }) {
    if (isEditing) {
      return TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          alignLabelWithHint: maxLines > 1,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
