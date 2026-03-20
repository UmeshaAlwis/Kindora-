import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kindora/providers/supabase_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kindora/l10n/app_localizations.dart';

class StartCampaignPage extends ConsumerStatefulWidget {
  const StartCampaignPage({super.key});

  @override
  ConsumerState<StartCampaignPage> createState() => _StartCampaignPageState();
}

class _StartCampaignPageState extends ConsumerState<StartCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String category = "Campaign";
  String campaignCategory = "Personal";
  bool _needsVolunteers = false;
  DateTime selectedDate = DateTime.now();

  XFile? selectedImageFile;
  String? uploadedImageUrl;

  late TextEditingController dateController;
  late TextEditingController titleController;
  late TextEditingController campaignerNameController;
  late TextEditingController targetAmountController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
    titleController = TextEditingController();
    campaignerNameController = TextEditingController();
    targetAmountController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    dateController.dispose();
    titleController.dispose();
    campaignerNameController.dispose();
    targetAmountController.dispose();
    descriptionController.dispose();
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
          selectedImageFile = image;
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
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await firebaseUser.getIdToken();

      // Create multipart request
      const String apiBaseUrl = 'http://10.0.2.2:5001/api';
      final uri = Uri.parse('$apiBaseUrl/storage/upload');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $idToken'
        ..fields['bucket'] = 'Kindora'
        ..fields['folder'] = 'campaigns'
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      print('[Campaign] Uploading image to backend: ${uri.toString()}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('[Campaign] Upload response: ${response.statusCode}');
      print('[Campaign] Response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final imageUrl = jsonResponse['url'] as String?;

        if (imageUrl != null) {
          print('[Campaign] Image uploaded successfully: $imageUrl');
          return imageUrl;
        }
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
    return null;
  }

  Future<void> _submitCampaign() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;

      // Upload image if selected
      if (selectedImageFile != null) {
        imageUrl = await _uploadImageToSupabase(selectedImageFile!);
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
      }

      final repository = ref.read(campaignRepositoryProvider);
      final targetAmount =
          double.tryParse(targetAmountController.text) ?? 1000.0;

      // Placeholder values for future enhancement (not in current schema)
      const String charityId = 'default-charity';
      const String beneficiaryDetails = 'Campaign beneficiary';
      const String beneficiaryLocation = 'General';

      await repository.createCampaign(
        title: titleController.text,
        campaignerName: campaignerNameController.text,
        category: category,
        campaignCategory: campaignCategory,
        needsVolunteers: _needsVolunteers,
        targetAmount: targetAmount,
        image: imageUrl,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        charityId: charityId,
        beneficiaryDetails: beneficiaryDetails,
        beneficiaryLocation: beneficiaryLocation,
        galleryUrls: [],
        endDate: selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Campaign created successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // Invalidate cache to refresh the campaigns list
        ref.invalidate(allCampaignsProvider);

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating campaign: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Campaign creation error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.startCampaign),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Image Section with Preview
              GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: selectedImageFile != null
                        ? Image.file(
                            File(selectedImageFile!.path),
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                l10n.chooseCampaignImage,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                l10n.campaignDetails,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C0C79),
                ),
              ),

              const SizedBox(height: 16),

              /// Title
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Title is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// Campaigner Name
              TextFormField(
                controller: campaignerNameController,
                decoration: InputDecoration(
                  labelText: l10n.campaignerName,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Campaigner name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// Date Picker
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF0C0C79),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0C0C79),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      dateController.text =
                          "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: l10n.campaignEndDate,
                      border: OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "End date is required";
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: l10n.mainCategory,
                  border: OutlineInputBorder(),
                ),
                items: ["Charity", "Campaign", "Donation"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              /// Campaign Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: campaignCategory,
                decoration: InputDecoration(
                  labelText: l10n.campaignType,
                  border: OutlineInputBorder(),
                ),
                items: ["Organization", "Personal"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    campaignCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _needsVolunteers,
                onChanged: (value) {
                  setState(() {
                    _needsVolunteers = value ?? false;
                  });
                },
                title: const Text('Need volunteers for this campaign'),
                subtitle: const Text('Donors can see if volunteer support is needed.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 8),

              /// Description (Optional)
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.campaignDescriptionOptional,
                  hintText: "Share details about your campaign...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// Image Selection Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text(
                    selectedImageFile != null
                        ? 'Change Image (${selectedImageFile!.name})'
                        : l10n.chooseCampaignImage,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Currency and Amount
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: "LKR",
                      items: ["LKR", "USD"]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (_) {},
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: targetAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        hintText: "100,000.00",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Amount is required";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await _submitCampaign();
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.createCampaign),
                    ),
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
