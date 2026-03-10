import 'package:supabase_flutter/supabase_flutter.dart';

class CampaignService {

  final supabase = Supabase.instance.client;

  Future<void> createCampaign({
    required String title,
    required String campaignerName,
    required String category,
    required String campaignCategory,
    required double targetAmount,
  }) async {

    await supabase.from('campaigns').insert({
      'title': title,
      'campaigner_name': campaignerName,
      'category': category,
      'campaign_category': campaignCategory,
      'target_amount': targetAmount,
    });

  }

  Future<List<dynamic>> getCampaigns() async {

    final data = await supabase
        .from('campaigns')
        .select();

    return data;

  }
}