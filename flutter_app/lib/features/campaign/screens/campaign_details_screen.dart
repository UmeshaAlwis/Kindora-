import 'package:flutter/material.dart';
import 'package:kindora/config/themes/app_colors.dart';
import 'package:kindora/features/payment/models/payment_model.dart' as payment_model;
import 'package:kindora/features/payment/ui/donation_amount_selection_page.dart';
import '../../../models/supabase_models.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailsScreen({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final targetAmount = campaign.targetAmount ?? 0.0;
    final raisedAmount = campaign.raisedAmount ?? 0.0;
    final progress = targetAmount > 0
        ? (raisedAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;

    final paymentCampaign = payment_model.Campaign(
      id: campaign.id,
      title: campaign.title,
      image: campaign.image ?? '',
      raisedAmount: raisedAmount,
      targetAmount: targetAmount,
      description: campaign.description ?? '',
    );

    String? dateLine;
    if (campaign.endDate != null) {
      final d = campaign.endDate!.toLocal();
      dateLine =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        title: const Text(
          'Campaign Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: campaign.image != null && campaign.image!.isNotEmpty
                        ? Image.network(
                            campaign.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        if (campaign.campaignerName != null &&
                            campaign.campaignerName!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  campaign.campaignerName!.trim(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (campaign.category != null &&
                            campaign.category!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.label_outline,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                campaign.category!.trim(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (dateLine != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ends $dateLine',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (campaign.description ?? '').trim().isEmpty
                              ? 'No description provided for this campaign.'
                              : campaign.description!.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: AppColors.border,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Raised LKR ${raisedAmount.toStringAsFixed(0)}'
                          '${targetAmount > 0 ? ' of LKR ${targetAmount.toStringAsFixed(0)}' : ''}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (targetAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}% of goal',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text(
                    'Support this campaign',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      builder: (ctx) => DonationAmountSelectionModal(
                        campaign: paymentCampaign,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.blueSurface,
      child: const Center(
        child: Icon(
          Icons.campaign,
          size: 72,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
