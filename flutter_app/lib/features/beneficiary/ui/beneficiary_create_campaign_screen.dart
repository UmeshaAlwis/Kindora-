import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../repositories/supabase_repositories.dart';
import '../../../config/app_env.dart';
import '../../../providers/supabase_providers.dart';

class BeneficiaryCreateCampaignScreen extends ConsumerStatefulWidget {
  const BeneficiaryCreateCampaignScreen({super.key});

  @override
  ConsumerState<BeneficiaryCreateCampaignScreen> createState() =>
      _BeneficiaryCreateCampaignScreenState();
}

class _BeneficiaryCreateCampaignScreenState
    extends ConsumerState<BeneficiaryCreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetAmountController;
  late TextEditingController _fullNameController;

  XFile? _selectedImageFile;

  final Color primaryColor = const Color(0xFF0C0C79);
  final Color accentColor = const Color(0xFFFF751F);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetAmountController = TextEditingController();
    _fullNameController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImageToSupabase(XFile imageFile) async {
    try {
      print('[CreateCampaign] Starting image upload: ${imageFile.name}');

      final file = File(imageFile.path);
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      // Get Firebase token for authentication
      final token = await firebaseUser.getIdToken();
      print('[CreateCampaign] Got auth token for upload');

      // Create multipart request
      final uri = Uri.parse('${AppEnv.apiBaseUrl}/storage/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add authentication header
      request.headers['Authorization'] = 'Bearer $token';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('image', file.path),
      );

      print('[CreateCampaign] Sending multipart request to: $uri');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('[CreateCampaign] Upload response status: ${response.statusCode}');
      print('[CreateCampaign] Upload response body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final imageUrl = data['data']?['url'] ?? data['url'];
        print('[CreateCampaign] ✓ Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        throw Exception(
            'Failed to upload image: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('[CreateCampaign] ✗ Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _submitCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      print(
          '[CreateCampaign] Starting campaign creation for Firebase UID: ${firebaseUser.uid}');

      // Get Supabase user ID from Firebase UID
      final supabase = Supabase.instance.client;
      final userResponse = await supabase
          .from('users')
          .select('id')
          .eq('firebase_uid', firebaseUser.uid)
          .maybeSingle();

      print('[CreateCampaign] User response: $userResponse');
      if (userResponse == null) {
        throw Exception('User not found in Supabase');
      }

      final supabaseUserId = userResponse['id'] as String;
      print('[CreateCampaign] Supabase User ID: $supabaseUserId');

      // Upload image if selected
      String? imageUrl;
      if (_selectedImageFile != null) {
        print('[CreateCampaign] Uploading image...');
        imageUrl = await _uploadImageToSupabase(_selectedImageFile!);
        print('[CreateCampaign] Image URL: $imageUrl');
      }

      print(
          '[CreateCampaign] Creating campaign with title: ${_titleController.text}');
      final repository = BeneficiaryCampaignRepository();
      final campaign = await repository.createBeneficiaryCampaign(
        beneficiaryUserId: supabaseUserId,
        fullName: _fullNameController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text.trim()),
        imageUrl: imageUrl,
      );
      print('[CreateCampaign] ✓ Campaign created: ${campaign.id}');

      // Invalidate the campaign provider to refresh the dashboard in real-time
      ref.invalidate(beneficiaryCampaignsByUserProvider(supabaseUserId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Wait 1 second before navigating to ensure database is updated
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/beneficiary/dashboard');
        }
      }
    } catch (e) {
      print('[CreateCampaign] ✗ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
        title: const Text('Create Fundraising Campaign'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: accentColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Share your story and set up a campaign to receive help.',
                            style: TextStyle(
                              fontSize: 14,
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campaign Image
                  Text(
                    'Campaign Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: primaryColor.withValues(alpha: 0.05),
                      ),
                      child: _selectedImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_selectedImageFile!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: primaryColor.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to select campaign image',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: primaryColor.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Full Name
                  Text(
                    'Your Full Name *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Campaign Title
                  Text(
                    'Campaign Title *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Give your campaign a compelling title',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor, width: 2),
                      ),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Campaign title is required';
                      }
                      if (value!.length < 10) {
                        return 'Title must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Campaign Description
                  Text(
                    'Campaign Story *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Tell your story. Explain why you need help and how donations will be used.',
                      prefixIcon: const Icon(Icons.description),
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
                        return 'Campaign description is required';
                      }
                      if (value!.length < 50) {
                        return 'Description must be at least 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Target Amount
                  Text(
                    'Fundraising Goal *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _targetAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter target amount',
                      prefixIcon: const Icon(Icons.attach_money),
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
                        return 'Target amount is required';
                      }
                      try {
                        final amount = double.parse(value!);
                        if (amount <= 0) {
                          return 'Amount must be greater than 0';
                        }
                      } catch (e) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitCampaign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[400],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Campaign',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
