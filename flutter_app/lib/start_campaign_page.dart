import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'services/campaign_services.dart';

class StartCampaignPage extends StatefulWidget {
  const StartCampaignPage({super.key});

  @override
  State<StartCampaignPage> createState() => _StartCampaignPageState();
}

class _StartCampaignPageState extends State<StartCampaignPage> {
  final _formKey = GlobalKey<FormState>();

  String category = "Campaign";
  String campaignCategory = "Personal";
  String priority = "Normal"; // ✅ Priority field
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;

  late TextEditingController dateController;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    dateController.dispose();
    titleController.dispose();
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _submitCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CampaignService().createCampaign(
        title: titleController.text.trim(),
        campaignerName: nameController.text.trim(),
        category: category,
        campaignCategory: campaignCategory,
        targetAmount: double.tryParse(amountController.text) ?? 0,
        priority: priority,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Campaign created successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Start a Campaign",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Image
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

              // Title
              TextFormField(
                controller: titleController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Campaigner Name
              TextFormField(
                controller: nameController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your name' : null,
                decoration: const InputDecoration(
                  labelText: "Campaigner Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Date Picker
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
                              foregroundColor: Color(0xFF0C0C79),
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
                      labelText: "Campaign Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: ["Charity", "Campaign", "Donation"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),

              const SizedBox(height: 16),

              // Campaign Category
              DropdownButtonFormField<String>(
                value: campaignCategory,
                decoration: const InputDecoration(
                  labelText: "Campaign Category",
                  border: OutlineInputBorder(),
                ),
                items: ["Organization", "Personal"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => campaignCategory = value!),
              ),

              const SizedBox(height: 16),

              // ✅ Priority Dropdown
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: "Priority",
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: "Normal",
                    child: Row(
                      children: const [
                        Icon(Icons.flag, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text("Normal"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "High",
                    child: Row(
                      children: const [
                        Icon(Icons.flag, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text("High"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Urgent",
                    child: Row(
                      children: const [
                        Icon(Icons.flag, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text("Urgent 🔴"),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => priority = value!),
              ),

              const SizedBox(height: 16),

              // Amount
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: "LKR",
                      items: ["LKR", "USD"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter an amount';
                        if ((double.tryParse(value) ?? 0) <= 0) return 'Enter a valid amount';
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "100,000.00",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Draft"),
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
                                color: Colors.white,
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