import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/supabase_models.dart';
import '../../../repositories/supabase_repositories.dart';
import '../../../providers/supabase_providers.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/app_env.dart';

class BeneficiaryCampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const BeneficiaryCampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  @override
  ConsumerState<BeneficiaryCampaignDetailScreen> createState() =>
      _BeneficiaryCampaignDetailScreenState();
}

class _BeneficiaryCampaignDetailScreenState
    extends ConsumerState<BeneficiaryCampaignDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetAmountController;
  bool _isEditing = false;
  bool _isLoading = false;
  XFile? _selectedImageFile;

  final Color primaryColor = const Color(0xFF0C0C79);
  final Color accentColor = const Color(0xFFFF751F);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<String?> _uploadImageToSupabase(XFile imageFile) async {
    try {
      final file = File(imageFile.path);

      // Create multipart request
      final uri = Uri.parse('${AppEnv.apiBaseUrl}/storage/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('image', file.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final imageUrl = data['data']?['url'] ?? data['url'];
        return imageUrl;
      } else {
        throw Exception(
            'Failed to upload image: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = pickedFile;
      });
    }
  }

  Future<void> _saveCampaign(BeneficiaryCampaign campaign) async {
    setState(() => _isLoading = true);

    try {
      String? imageUrl = campaign.imageUrl;

      // Upload new image if selected
      if (_selectedImageFile != null) {
        imageUrl = await _uploadImageToSupabase(_selectedImageFile!);
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
      }

      final repository = BeneficiaryCampaignRepository();
      await repository.updateBeneficiaryCampaign(
        campaignId: campaign.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text.trim()),
        imageUrl: imageUrl,
      );

      // Invalidate provider to refresh
      ref.invalidate(
          beneficiaryCampaignsByUserProvider(campaign.beneficiaryUserId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCampaign(BeneficiaryCampaign campaign) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                final repository = BeneficiaryCampaignRepository();
                await repository.deleteBeneficiaryCampaign(campaign.id);

                // Invalidate provider to refresh
                ref.invalidate(beneficiaryCampaignsByUserProvider(
                    campaign.beneficiaryUserId));

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Campaign deleted successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Wait for snackbar to display, then navigate to home
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) {
                    context.go('/');
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(beneficiaryCampaignByIdProvider(widget.campaignId)).when(
          data: (campaign) {
            if (campaign == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Campaign Details')),
                body: const Center(child: Text('Campaign not found')),
              );
            }

            // Initialize controllers on first build
            if (!_isEditing) {
              _titleController.text = campaign.title;
              _descriptionController.text = campaign.description;
              _targetAmountController.text =
                  campaign.targetAmount.toStringAsFixed(2);
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Campaign Details'),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                actions: [
                  if (!_isEditing)
                    PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          setState(() => _isEditing = true);
                        } else if (value == 'delete') {
                          _deleteCampaign(campaign);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Campaign'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Campaign',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                ],
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campaign Image
                          if (_selectedImageFile != null)
                            Container(
                              width: double.infinity,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image:
                                      FileImage(File(_selectedImageFile!.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else if (campaign.imageUrl != null)
                            Container(
                              width: double.infinity,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image: NetworkImage(campaign.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Campaign Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: campaign.status == 'active'
                                        ? Colors.green
                                        : Colors.orange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    campaign.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Title
                                if (_isEditing)
                                  TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      labelText: 'Campaign Title',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    campaign.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0C0C79),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                // Full Name
                                Text(
                                  'By: ${campaign.fullName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Progress Bar
                                ClipRounded(campaign),
                                const SizedBox(height: 16),
                                // Target and Raised
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Raised',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '\$${campaign.raisedAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Goal',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (_isEditing)
                                            TextField(
                                              controller:
                                                  _targetAmountController,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            )
                                          else
                                            Text(
                                              '\$${campaign.targetAmount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Description
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_isEditing)
                                  TextField(
                                    controller: _descriptionController,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    campaign.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.6,
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                // Change Image Button (only in edit mode)
                                if (_isEditing) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(Icons.image),
                                      label: const Text('Change Image'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                // Edit/Save Buttons
                                if (_isEditing)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isEditing = false;
                                              _selectedImageFile = null;
                                              _titleController.text =
                                                  campaign.title;
                                              _descriptionController.text =
                                                  campaign.description;
                                              _targetAmountController.text =
                                                  campaign.targetAmount
                                                      .toStringAsFixed(2);
                                            });
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _saveCampaign(campaign),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Save Changes'),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Campaign Details')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Campaign Details')),
            body: Center(child: Text('Error: $error')),
          ),
        );
  }
}

class ClipRounded extends StatelessWidget {
  final BeneficiaryCampaign campaign;

  const ClipRounded(this.campaign, {super.key});

  @override
  Widget build(BuildContext context) {
    final percentage = (campaign.raisedAmount / campaign.targetAmount) * 100;
    final displayPercentage = percentage > 100 ? 100.0 : percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${displayPercentage.toStringAsFixed(1)}% Funded',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: displayPercentage / 100,
            minHeight: 8,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF751F)),
            backgroundColor: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}
