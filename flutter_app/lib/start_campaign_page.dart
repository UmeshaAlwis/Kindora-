import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'services/campaign_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class StartCampaignPage extends StatefulWidget {
  const StartCampaignPage({super.key});

  @override
  State<StartCampaignPage> createState() => _StartCampaignPageState();
}

class _StartCampaignPageState extends State<StartCampaignPage> {
  final _formKey = GlobalKey<FormState>();

  String category = "Campaign";
  String campaignCategory = "Personal";
  DateTime selectedDate = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start a Campaign"),
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          
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
              ),

              const SizedBox(height: 16),

              /// Campaigner Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Campaigner Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// Date Picker (FIXED)
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
            primary: Color(0xFF0C0C79), // Header & selected date color
            onPrimary: Colors.white,    // Text color on header
            onSurface: Colors.black,    // Default text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF0C0C79),
               // OK & Cancel color
            ),
          ),                    hoverColor: const Color(0xFFFF751F).withOpacity(0.15),
  splashColor: const Color(0xFFFF751F).withOpacity(0.25),
  highlightColor: const Color.fromARGB(0, 0, 0, 0),
        ),
        child: child!,      );
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

              /// Category Dropdown
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: "Category",
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
                value: campaignCategory,
                decoration: const InputDecoration(
                  labelText: "Campaign Category",
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

              /// Donation Required
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: "LKR",
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
                    controller: nameController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      hintText: "100,000.00",
                      border: OutlineInputBorder(),
                    ),
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
                      onPressed: () {},
                      child: const Text("Draft"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {

                        final supabase = Supabase.instance.client;

                        final title = titleController.text;
                        final amount = double.tryParse(amountController.text) ?? 0;

                        await supabase.from('campaigns').insert({
                          'title': title,
                          'target_amount': amount,
                          'raised_amount': 0
                        });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Campaign created successfully")),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Create campaign"),
              )
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
