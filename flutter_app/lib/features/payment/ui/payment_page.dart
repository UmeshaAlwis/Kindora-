import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../models/payment_model.dart';
import 'package:kindora/services/wallet_service.dart';
import 'package:kindora/config/app_env.dart';
import 'bank_transfer_page.dart';

class _CardNumberInputFormatter extends TextInputFormatter {
  /// Formats card numbers as `1234 5678 9012 3456` while keeping only digits.
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmedDigits =
        digitsOnly.length > 19 ? digitsOnly.substring(0, 19) : digitsOnly;

    final formatted = _format(trimmedDigits);

    // Preserve cursor position based on digit count before the cursor.
    final selectionBaseOffset = newValue.selection.baseOffset;
    final beforeCursor = newValue.text.substring(
      0,
      selectionBaseOffset.clamp(0, newValue.text.length),
    );
    final digitsBeforeCursor = beforeCursor.replaceAll(RegExp(r'\D'), '');
    final digitsCount = digitsBeforeCursor.length;

    final formattedCursorOffset = _cursorOffsetFromDigits(
      trimmedDigits: trimmedDigits,
      digitsBeforeCursorCount: digitsCount,
      formatted: formatted,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formattedCursorOffset),
    );
  }

  String _format(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final isGroupEnd = (i + 1) % 4 == 0;
      final isLastDigit = i == digits.length - 1;
      if (isGroupEnd && !isLastDigit) buffer.write(' ');
    }
    return buffer.toString();
  }

  int _cursorOffsetFromDigits({
    required String trimmedDigits,
    required int digitsBeforeCursorCount,
    required String formatted,
  }) {
    final count = digitsBeforeCursorCount.clamp(0, trimmedDigits.length);
    // Build the formatted prefix for `count` digits.
    final prefix = _format(trimmedDigits.substring(0, count));
    return prefix.length;
  }
}

class PaymentPage extends StatefulWidget {
  final Campaign campaign;
  final double? preSelectedAmount;
  final String? beneficiaryCampaignId;
  final String donationType;
  final String? recurringFrequency;
  final DateTime? recurringEndDate;

  const PaymentPage({
    super.key,
    required this.campaign,
    this.preSelectedAmount,
    this.beneficiaryCampaignId,
    this.donationType = 'one-time',
    this.recurringFrequency,
    this.recurringEndDate,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late TextEditingController _amountController;
  late TextEditingController _donorNameController;
  late TextEditingController _donorEmailController;
  late TextEditingController _donorPhoneController;
  late TextEditingController _wishController;
  String _selectedPaymentMethod = 'stripe';
  bool _isProcessing = false;
  bool _isAnonymous = false;
  double _walletBalance = 0.0;
  late WalletService _walletService;

  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'wallet',
      name: 'Wallet',
      icon: '👛',
      description: 'Use your app wallet balance',
    ),
    PaymentMethod(
      id: 'stripe',
      name: 'Card Payments',
      icon: '💳',
      description: 'Credit/Debit Card',
    ),
    PaymentMethod(
      id: 'bank_transfer',
      name: 'Bank Transfer',
      icon: '🏦',
      description: 'Upload receipt for verification',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _donorNameController = TextEditingController();
    _donorEmailController = TextEditingController();
    _donorPhoneController = TextEditingController();
    _wishController = TextEditingController();
    _walletService = WalletService();

    // Recurring donations are currently processed using wallet payments.
    if (widget.donationType == 'recurring') {
      _selectedPaymentMethod = 'wallet';
    }

    // Set pre-selected amount if provided
    if (widget.preSelectedAmount != null) {
      _amountController.text = widget.preSelectedAmount!.toStringAsFixed(0);
    }

    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    if (!mounted) return;

    try {
      final balance = await _walletService.getWalletBalance();
      if (mounted) {
        setState(() {
          _walletBalance = balance;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _donorNameController.dispose();
    _donorEmailController.dispose();
    _donorPhoneController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  double get _donationAmount {
    return double.tryParse(_amountController.text) ?? 0.0;
  }

  void _processPayment() async {
    if (_amountController.text.isEmpty ||
        _donorNameController.text.isEmpty ||
        _donorEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Phone number is required for bank transfer only
    if (_selectedPaymentMethod == 'bank_transfer' &&
        _donorPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter phone number for bank transfer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Recurring payments are currently wallet-based only.
    if (widget.donationType == 'recurring') {
      if (_selectedPaymentMethod != 'wallet') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recurring donations use Wallet payments only'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (widget.recurringFrequency == null || widget.recurringEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select recurring frequency and end date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate wallet balance for wallet payments
    if (_selectedPaymentMethod == 'wallet') {
      if (_walletBalance < _donationAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient wallet balance. Available: LKR ${_walletBalance.toStringAsFixed(2)}, Required: LKR ${_donationAmount.toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final orderId =
          'kindora_${DateTime.now().millisecondsSinceEpoch.toString()}';

      final payment = Payment(
        id: orderId,
        campaignId: widget.campaign.id,
        campaignTitle: widget.campaign.title,
        amount: _donationAmount,
        paymentMethod: _selectedPaymentMethod,
        timestamp: DateTime.now(),
        status: 'Processing',
        donorName: _donorNameController.text,
        donorEmail: _donorEmailController.text,
      );

      if (_selectedPaymentMethod == 'wallet') {
        // Handle wallet payment
        await _processWalletPayment(
            payment, orderId, widget.beneficiaryCampaignId);
      } else if (_selectedPaymentMethod == 'stripe') {
        // Handle Stripe payment
        await _processStripePayment(payment, orderId);
      } else if (_selectedPaymentMethod == 'bank_transfer') {
        // Handle bank transfer
        await _processBankTransfer(payment);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processWalletPayment(
      Payment payment, String orderId, String? beneficiaryCampaignId) async {
    try {
      // Process wallet payment through the service
      await _walletService.processWalletPayment(
        amount: _donationAmount,
        campaignId: widget.campaign.id,
        beneficiaryCampaignId: beneficiaryCampaignId,
        donorName: _donorNameController.text,
        donorEmail: _donorEmailController.text,
        donationType: widget.donationType,
        recurringFrequency: widget.recurringFrequency,
        recurringEndDate: widget.recurringEndDate,
      );

      if (!mounted) return;

      // Show success dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet donation successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Update wallet balance
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _walletBalance -= _donationAmount;
        });
      }

      // Navigate back after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallet payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processStripePayment(Payment payment, String orderId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();
      final isBeneficiaryDonation = widget.beneficiaryCampaignId != null &&
          widget.beneficiaryCampaignId!.isNotEmpty;

      // Step 1: Create card intent (creates donation row as "pending")
      final createIntentUrl = isBeneficiaryDonation
          ? '${AppEnv.apiBaseUrl}/beneficiary-donations/card/create-intent'
          : '${AppEnv.apiBaseUrl}/donations/card/create-intent';

      final message = _wishController.text.trim();

      final createBody = isBeneficiaryDonation
          ? {
              'beneficiary_campaign_id': widget.beneficiaryCampaignId,
              'amount': _donationAmount,
              'donor_name': _donorNameController.text.trim(),
              'donor_email': _donorEmailController.text.trim(),
              'is_anonymous': _isAnonymous,
            }
          : {
              'campaign_id': widget.campaign.id,
              'amount': _donationAmount,
              'donor_name': _donorNameController.text.trim(),
              'donor_email': _donorEmailController.text.trim(),
              'is_anonymous': _isAnonymous,
            };

      // `donor_phone` is optional and your card UI doesn't ask for it.
      // Omit it when empty to satisfy backend Joi validation.
      final phone = _donorPhoneController.text.trim();
      if (phone.isNotEmpty) {
        createBody['donor_phone'] = phone;
      }

      if (message.isNotEmpty) {
        createBody['message'] = message;
      }

      final createResponse = await http.post(
        Uri.parse(createIntentUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(createBody),
      );

      final createJson = jsonDecode(createResponse.body);
      if (createResponse.statusCode != 200 || createJson['success'] != true) {
        throw Exception(createJson['error'] ?? 'Failed to create card intent');
      }

      final donationId = createJson['data']?['donation_id']?.toString();
      if (donationId == null || donationId.isEmpty) {
        throw Exception('Failed to get donation_id for card payment');
      }

      // Step 2: Show a Stripe-like card form (simulated payment UI)
      final shouldPay = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool isValidLuhn(String digits) {
            if (digits.length < 12) return false;
            int sum = 0;
            bool alternate = false;
            for (int i = digits.length - 1; i >= 0; i--) {
              int n = int.tryParse(digits[i]) ?? 0;
              if (alternate) {
                n *= 2;
                if (n > 9) n -= 9;
              }
              sum += n;
              alternate = !alternate;
            }
            return sum % 10 == 0;
          }

          String digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

          bool isExpiryValid(String exp) {
            final match =
                RegExp(r'^(\d{2})/(\d{2})$').firstMatch(exp.trim());
            if (match == null) return false;
            final month = int.tryParse(match.group(1) ?? '') ?? 0;
            final yy = int.tryParse(match.group(2) ?? '') ?? -1;
            if (month < 1 || month > 12 || yy < 0) return false;

            final now = DateTime.now();
            final fullYear = 2000 + yy;
            final lastDayOfMonth = DateTime(fullYear, month + 1, 0);
            return !lastDayOfMonth.isBefore(DateTime(now.year, now.month, 1));
          }

          String normalizeExpiry(String v) {
            final raw = digitsOnly(v);
            if (raw.length <= 2) return raw;
            if (raw.length <= 4) {
              return '${raw.substring(0, 2)}/${raw.substring(2)}';
            }
            return v;
          }

          final formKey = GlobalKey<FormState>();
          final cardNumberController = TextEditingController();
          final nameController = TextEditingController();
          final expController = TextEditingController();
          final cvcController = TextEditingController();
          final zipController = TextEditingController();

          Widget _fieldLabel(String text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                ),
              );

          InputDecoration _inputDecoration(String hint) => InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF751F)),
                ),
              );

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final brand = 'CARD';
                    final cardDigits = digitsOnly(cardNumberController.text);
                    final masked = cardDigits.length >= 4
                        ? '•••• ${cardDigits.substring(cardDigits.length - 4)}'
                        : '•••• •••• •••• ••••';

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Card Payments',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0C0C79), Color(0xFF001A4D)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brand,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                masked,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                nameController.text.isNotEmpty
                                    ? nameController.text.trim().toUpperCase()
                                    : 'CARD HOLDER',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              _fieldLabel('Card number'),
                              TextFormField(
                                controller: cardNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  _CardNumberInputFormatter(),
                                ],
                                decoration: _inputDecoration('4242 4242 4242 4242'),
                                validator: (v) {
                                  final digits = digitsOnly(v ?? '');
                                  if (digits.isEmpty) {
                                    return 'Card number is required';
                                  }
                                  if (digits.length < 12 || digits.length > 19) {
                                    return 'Card number length is invalid';
                                  }
                                  if (!isValidLuhn(digits)) {
                                    return 'Card number is invalid';
                                  }
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              _fieldLabel('Name on card'),
                              TextFormField(
                                controller: nameController,
                                decoration: _inputDecoration('e.g. John Doe'),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) {
                                  final t = (v ?? '').trim();
                                  if (t.isEmpty) return 'Name on card is required';
                                  if (t.length < 3) return 'Name is too short';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _fieldLabel('Expiry'),
                                        TextFormField(
                                          controller: expController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration:
                                              _inputDecoration('MM/YY'),
                                          onChanged: (v) {
                                            final normalized =
                                                normalizeExpiry(v);
                                            if (normalized != expController.text) {
                                              expController.value =
                                                  TextEditingValue(
                                                      text: normalized,
                                                      selection: TextSelection
                                                          .fromPosition(
                                                              TextPosition(
                                                                  offset: normalized.length)));
                                            }
                                          },
                                          validator: (v) {
                                            final exp = expController.text.trim();
                                            if (exp.isEmpty) {
                                              return 'Expiry is required';
                                            }
                                            if (!RegExp(r'^\d{2}/\d{2}$')
                                                .hasMatch(exp)) {
                                              return 'Use MM/YY format';
                                            }
                                            if (!isExpiryValid(exp)) {
                                              return 'Card is expired';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _fieldLabel('CVC'),
                                        TextFormField(
                                          controller: cvcController,
                                          keyboardType: TextInputType.number,
                                          obscureText: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: _inputDecoration('123'),
                                          validator: (v) {
                                            final cvc = digitsOnly(v ?? '');
                                            if (cvc.isEmpty) {
                                              return 'CVC is required';
                                            }
                                            if (cvc.length < 3 || cvc.length > 4) {
                                              return 'CVC must be 3-4 digits';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _fieldLabel('Billing ZIP (optional)'),
                              TextFormField(
                                controller: zipController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: _inputDecoration('e.g. 10001'),
                                validator: (v) {
                                  final zip = digitsOnly(v ?? '');
                                  if (zip.isEmpty) return null; // optional
                                  if (zip.length < 4 || zip.length > 10) {
                                    return 'ZIP looks invalid';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final ok = formKey.currentState?.validate() ?? false;
                                  if (!ok) return;
                                  Navigator.pop(dialogContext, true);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: const Color(0xFF0C0C79),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Pay',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      );

      if (shouldPay == true) {
        // Step 3a: Confirm card payment (marks donation success/completed)
        final confirmUrl = isBeneficiaryDonation
            ? '${AppEnv.apiBaseUrl}/beneficiary-donations/card/confirm-payment'
            : '${AppEnv.apiBaseUrl}/donations/card/confirm-payment';

        final confirmResponse = await http.post(
          Uri.parse(confirmUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'donation_id': donationId,
            'transaction_id': orderId,
          }),
        );

        final confirmJson = jsonDecode(confirmResponse.body);
        if (confirmResponse.statusCode != 200 || confirmJson['success'] != true) {
          throw Exception(confirmJson['error'] ?? 'Card payment failed');
        }

        if (!mounted) return;
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);
      } else {
        // Step 3b: Cancel card payment intent to avoid leaving pending rows
        final cancelUrl = isBeneficiaryDonation
            ? '${AppEnv.apiBaseUrl}/beneficiary-donations/card/cancel-payment'
            : '${AppEnv.apiBaseUrl}/donations/card/cancel-payment';

        try {
          await http.post(
            Uri.parse(cancelUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'donation_id': donationId,
              'transaction_id': orderId,
            }),
          );
        } catch (_) {
          // ignore cancel failure
        }

        if (!mounted) return;
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, false);
      }
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card payment failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _processBankTransfer(Payment payment) async {
    setState(() => _isProcessing = false);

    if (mounted) {
      // Navigate to bank transfer page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BankTransferPage(
            campaign: widget.campaign,
            amount: _donationAmount,
            donorName: _donorNameController.text,
            donorEmail: _donorEmailController.text,
            donorPhone: _donorPhoneController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaign.title),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Banner
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transaction only via application!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donation Amount Section (Simplified)
            const Text(
              'Donation Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: 'LKR',
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'LKR', child: Text(' LKR')),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donor Information Section
            const Text(
              'Donor Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _donorNameController,
              decoration: InputDecoration(
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _donorEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedPaymentMethod == 'bank_transfer')
              TextField(
                controller: _donorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() => _isAnonymous = value ?? false);
                  },
                ),
                const Expanded(
                  child: Text(
                    'Hide your name as anonym',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Write your wish and encouragement',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _wishController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                counterText: '${_wishController.text.length}/200',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),

            // Payment Method Section
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...paymentMethods.map((method) {
              final isWallet = method.id == 'wallet';
              final walletDisplay = isWallet
                  ? ' (Balance: LKR ${_walletBalance.toStringAsFixed(2)})'
                  : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedPaymentMethod = method.id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPaymentMethod == method.id
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[300]!,
                        width: _selectedPaymentMethod == method.id ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Radio<String>(
                        value: method.id,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                      ),
                      title: Row(
                        children: [
                          Text(method.icon,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.name + walletDisplay,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  method.description ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
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
                ),
              );
            }),
            const SizedBox(height: 24),

            // Order Summary
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Donation Amount:'),
                      Text(
                        'LKR ${_donationAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (_selectedPaymentMethod != 'wallet' &&
                      _selectedPaymentMethod != 'stripe') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Processing Fee:'),
                        Text(
                          'LKR ${(_donationAmount * 0.02).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'LKR ${(_selectedPaymentMethod == 'wallet' || _selectedPaymentMethod == 'stripe' ? _donationAmount : _donationAmount + (_donationAmount * 0.02)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001A4D),
                  disabledBackgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(
                  _isProcessing ? 'Processing...' : 'Donate Now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Security Info
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment information is secured with SSL encryption',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
