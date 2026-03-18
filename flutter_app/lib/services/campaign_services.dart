import 'package:supabase_flutter/supabase_flutter.dart';

class CampaignService {
  final supabase = Supabase.instance.client;

  // ─── CAMPAIGNS ───────────────────────────────────────────

  Future<void> createCampaign({
    required String title,
    required String campaignerName,
    required String category,
    required String campaignCategory,
    required double targetAmount,
    required String priority,
  }) async {
    try {
      await supabase.from('campaigns').insert({
        'title': title,
        'campaigner_name': campaignerName,
        'category': category,
        'campaign_category': campaignCategory,
        'target_amount': targetAmount,
        'raised_amount': 0,
        'priority': priority,
      });
    } catch (e) {
      throw Exception('Failed to create campaign: $e');
    }
  }

  Future<List<dynamic>> getCampaigns() async {
    try {
      final data = await supabase
          .from('campaigns')
          .select()
          .order('created_at', ascending: false);
      return data;
    } catch (e) {
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  // Fetches only Urgent priority campaigns for dashboard
  Future<List<dynamic>> getUrgentCampaigns() async {
    try {
      final data = await supabase
          .from('campaigns')
          .select()
          .eq('priority', 'Urgent')
          .order('created_at', ascending: false)
          .limit(4);
      return data;
    } catch (e) {
      throw Exception('Failed to fetch urgent campaigns: $e');
    }
  }

  // ─── CHARITY CAUSES ──────────────────────────────────────

  Future<List<dynamic>> getCharityCauses() async {
    try {
      final data = await supabase
          .from('charity_causes')
          .select()
          .order('created_at', ascending: false);
      return data;
    } catch (e) {
      throw Exception('Failed to fetch causes: $e');
    }
  }
}