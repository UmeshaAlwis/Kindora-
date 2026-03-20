import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/supabase_models.dart';
import '../../../providers/supabase_providers.dart';
import '../../messages/services/direct_message_service.dart';
import '../../messages/ui/direct_chat_page.dart';
import '../../payment/models/payment_model.dart' as payment_model;
import '../../payment/ui/beneficiary_donation_amount_selection_page.dart';

class BeneficiaryCampaignInfoPage extends ConsumerStatefulWidget {
  final BeneficiaryCampaign campaign;

  const BeneficiaryCampaignInfoPage({
    super.key,
    required this.campaign,
  });

  @override
  ConsumerState<BeneficiaryCampaignInfoPage> createState() =>
      _BeneficiaryCampaignInfoPageState();
}

class _BeneficiaryCampaignInfoPageState
    extends ConsumerState<BeneficiaryCampaignInfoPage> {
  final DirectMessageService _messageService = DirectMessageService();
  bool _checkingRole = false;

  Future<void> _startChat() async {
    setState(() => _checkingRole = true);
    try {
      final isDonor = await _messageService.isCurrentUserDonor();
      if (!isDonor) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only donors can start a new chat.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DirectChatPage(
            receiverId: widget.campaign.beneficiaryUserId,
            receiverName: widget.campaign.fullName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingRole = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0C0C79);
    const accentColor = Color(0xFFFF751F);
    final campaignAsync =
        ref.watch(beneficiaryCampaignByIdProvider(widget.campaign.id));
    final campaign = campaignAsync.valueOrNull ?? widget.campaign;
    final baseProgress = campaign.targetAmount <= 0
        ? 0.0
        : (campaign.raisedAmount / campaign.targetAmount).clamp(0.0, 1.0);
    final progress = campaign.raisedAmount > 0 && baseProgress < 0.01
        ? 0.01
        : baseProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Information'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (campaign.imageUrl != null)
              Image.network(
                campaign.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${campaign.fullName}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Raised: LKR ${campaign.raisedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Goal: LKR ${campaign.targetAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Story',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.description,
                    style: TextStyle(color: Colors.grey[800], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final shouldRefresh = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) =>
                              BeneficiaryDonationAmountSelectionModal(
                            campaign: payment_model.Campaign(
                              id: campaign.id,
                              title: campaign.title,
                              image: campaign.imageUrl ?? '',
                              raisedAmount: campaign.raisedAmount,
                              targetAmount: campaign.targetAmount,
                              description: campaign.description,
                            ),
                            beneficiaryCampaignId: campaign.id,
                          ),
                        );

                        if (!mounted) return;
                        if (shouldRefresh == true) {
                          ref.invalidate(
                            beneficiaryCampaignByIdProvider(widget.campaign.id),
                          );
                        }

                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Donate Now'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: primaryColor),
                        foregroundColor: primaryColor,
                      ),
                      onPressed: _checkingRole ? null : _startChat,
                      icon: _checkingRole
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message Beneficiary'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
