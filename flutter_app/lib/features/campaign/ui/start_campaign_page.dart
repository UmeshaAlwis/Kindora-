import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/campaign_service.dart';

class StartCampaignPage extends StatefulWidget {
  const StartCampaignPage({super.key});

  @override
  State<StartCampaignPage> createState() => _StartCampaignPageState();
}

class _StartCampaignPageState extends State<StartCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String category = "Campaign";
  String campaignCategory = "Personal";
  DateTime selectedDate = DateTime.now();

  late TextEditingController dateController;
  late TextEditingController titleController;
  late TextEditingController campaignerNameController;
  late TextEditingController targetAmountController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
    titleController = TextEditingController();
    campaignerNameController = TextEditingController();
    targetAmountController = TextEditingController();
  }

  @override
  void dispose() {
    dateController.dispose();
    titleController.dispose();
    campaignerNameController.dispose();
    targetAmountController.dispose();
    super.dispose();
  }

  /// Submit campaign to backend
  Future<void> _submitCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Get auth token from Firebase/Auth service
      const String authToken = 'placeholder_token';
      
      // TODO: Get charity ID from current user
      const String charityId = 'default_charity';

      final request = CreateCampaignRequest(
        title: titleController.text.trim(),
        description: campaignerNameController.text.trim(),
        category: category,
        targetAmount: double.parse(targetAmountController.text),
        beneficiaryDetails: campaignerNameController.text,
        endDate: selectedDate,
        charityId: charityId,
      );

      final campaignId = await CampaignService.createCampaign(
        request,
        authToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Campaign created successfully (ID: $campaignId)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
        title: const Text("Start a Campaign"),
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
              /// Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://images.unsplash.com/photo-1593113630400-ea4288922497",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Campaign Details",
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
                decoration: const InputDecoration(
                  labelText: "Campaigner Name",
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
                    decoration: const InputDecoration(
                      labelText: "Campaign End Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
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
                decoration: const InputDecoration(
                  labelText: "Main Category",
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
                decoration: const InputDecoration(
                  labelText: "Campaign Type",
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

              /// Target Amount
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
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitCampaign,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Create Campaign"),
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
