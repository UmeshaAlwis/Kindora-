import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/supabase_models.dart';
import '../services/supabase_service.dart';
import '../config/app_env.dart';

class CampaignRepository {
  final SupabaseClient _supabase;

  CampaignRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch all campaigns via backend API
  Future<List<Campaign>> getAllCampaigns() async {
    try {
      print('[CampaignRepository] Fetching campaigns from backend API...');
      final dio = Dio();
      final apiUrl = '${AppEnv.apiBaseUrl}/campaigns';
      print('[CampaignRepository] API URL: $apiUrl');

      final response = await dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('[CampaignRepository] Response status: ${response.statusCode}');
      print('[CampaignRepository] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final campaignsList = (data['data'] as List)
            .map((json) => Campaign.fromJson(json))
            .toList();
        print(
            '[CampaignRepository] Successfully parsed ${campaignsList.length} campaigns');
        return campaignsList;
      } else {
        throw Exception('Failed to fetch campaigns: ${response.statusCode}');
      }
    } catch (e) {
      print('[CampaignRepository] ERROR: $e');
      print('[CampaignRepository] Stack: ${StackTrace.current}');
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  /// Fetch campaign by ID
  Future<Campaign?> getCampaignById(String campaignId) async {
    try {
      final response = await _supabase
          .from('campaigns')
          .select()
          .eq('id', campaignId)
          .single();
      return Campaign.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch campaign: $e');
    }
  }

  /// Fetch campaigns by category
  Future<List<Campaign>> getCampaignsByCategory(String category) async {
    try {
      final response =
          await _supabase.from('campaigns').select().eq('category', category);
      return (response as List).map((data) => Campaign.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch campaigns by category: $e');
    }
  }

  /// Create new campaign via backend API
  Future<Campaign> createCampaign({
    required String title,
    String? campaignerName,
    String? category,
    String? campaignCategory,
    double? targetAmount,
    String? image,
    String? description,
    String? charityId,
    String? beneficiaryDetails,
    String? beneficiaryLocation,
    List<String>? galleryUrls,
    DateTime? endDate,
  }) async {
    try {
      final dio = Dio();
      final apiUrl = '${AppEnv.apiBaseUrl}/campaigns';
      print('[CampaignRepository] Creating campaign at: $apiUrl');

      // Only send fields that exist in the campaigns table schema
      final data = {
        'title': title,
        'campaigner_name': campaignerName,
        'category': category,
        'campaign_category': campaignCategory,
        'target_amount': targetAmount ?? 1000.0,
        'image_url': image,
      };
      print('[CampaignRepository] Request payload: $data');

      // Get Firebase ID token for authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final idToken = await user.getIdToken();

      final response = await dio.post(
        apiUrl,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      print(
          '[CampaignRepository] Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final campaign = Campaign.fromJson(response.data[0] ?? response.data);
        print('[CampaignRepository] Campaign created: ${campaign.id}');
        return campaign;
      } else {
        throw Exception('Failed to create campaign: ${response.statusMessage}');
      }
    } catch (e) {
      print('[CampaignRepository] ERROR: $e');
      throw Exception('Failed to create campaign: $e');
    }
  }

  /// Update campaign
  Future<Campaign> updateCampaign({
    required String campaignId,
    String? title,
    String? campaignerName,
    String? category,
    double? targetAmount,
    String? image,
    String? description,
    double? raisedAmount,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) {
        updateData['title'] = title;
      }
      if (campaignerName != null) {
        updateData['campaigner_name'] = campaignerName;
      }
      if (category != null) {
        updateData['category'] = category;
      }
      if (targetAmount != null) {
        updateData['target_amount'] = targetAmount;
      }
      if (image != null) {
        updateData['image'] = image;
      }
      if (description != null) {
        updateData['description'] = description;
      }
      if (raisedAmount != null) {
        updateData['raised_amount'] = raisedAmount;
      }

      final response = await _supabase
          .from('campaigns')
          .update(updateData)
          .eq('id', campaignId)
          .select()
          .single();
      return Campaign.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update campaign: $e');
    }
  }

  /// Delete campaign
  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _supabase.from('campaigns').delete().eq('id', campaignId);
    } catch (e) {
      throw Exception('Failed to delete campaign: $e');
    }
  }
}

class CharityRepository {
  final SupabaseClient _supabase;

  CharityRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch all charities
  Future<List<Charity>> getAllCharities() async {
    try {
      final response = await _supabase.from('charities').select();
      return (response as List).map((data) => Charity.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch charities: $e');
    }
  }

  /// Fetch charity by ID
  Future<Charity?> getCharityById(String charityId) async {
    try {
      final response = await _supabase
          .from('charities')
          .select()
          .eq('id', charityId)
          .single();
      return Charity.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch charity: $e');
    }
  }

  /// Fetch charities by category
  Future<List<Charity>> getCharitiesByCategory(String category) async {
    try {
      final response =
          await _supabase.from('charities').select().eq('category', category);
      return (response as List).map((data) => Charity.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch charities by category: $e');
    }
  }

  /// Create new charity
  Future<Charity> createCharity({
    required String name,
    String? description,
    String? imageUrl,
    String? category,
  }) async {
    try {
      final response = await _supabase
          .from('charities')
          .insert({
            'name': name,
            'description': description,
            'image_url': imageUrl,
            'category': category,
            'amount_raised': 0,
          })
          .select()
          .single();
      return Charity.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create charity: $e');
    }
  }

  /// Update charity
  Future<Charity> updateCharity({
    required String charityId,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    double? amountRaised,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) {
        updateData['name'] = name;
      }
      if (description != null) {
        updateData['description'] = description;
      }
      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }
      if (category != null) {
        updateData['category'] = category;
      }
      if (amountRaised != null) {
        updateData['amount_raised'] = amountRaised;
      }
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('charities')
          .update(updateData)
          .eq('id', charityId)
          .select()
          .single();
      return Charity.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update charity: $e');
    }
  }
}

class DonationRepository {
  final SupabaseClient _supabase;

  DonationRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch all donations
  Future<List<Donation>> getAllDonations() async {
    try {
      final response = await _supabase.from('donations').select();
      return (response as List).map((data) => Donation.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch donations: $e');
    }
  }

  /// Fetch donations by user ID
  Future<List<Donation>> getDonationsByUserId(String userId) async {
    try {
      final response =
          await _supabase.from('donations').select().eq('user_id', userId);
      return (response as List).map((data) => Donation.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user donations: $e');
    }
  }

  /// Fetch donations by charity ID
  Future<List<Donation>> getDonationsByCharityId(String charityId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select()
          .eq('charity_id', charityId);
      return (response as List).map((data) => Donation.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch charity donations: $e');
    }
  }

  /// Create new donation
  Future<Donation> createDonation({
    String? userId,
    String? charityId,
    required double amount,
    String currency = 'USD',
    String? paymentMethod,
    String status = 'pending',
  }) async {
    try {
      final response = await _supabase
          .from('donations')
          .insert({
            'user_id': userId,
            'charity_id': charityId,
            'amount': amount,
            'currency': currency,
            'payment_method': paymentMethod,
            'status': status,
          })
          .select()
          .single();
      return Donation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  /// Update donation status
  Future<Donation> updateDonationStatus({
    required String donationId,
    required String status,
  }) async {
    try {
      final response = await _supabase
          .from('donations')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', donationId)
          .select()
          .single();
      return Donation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update donation: $e');
    }
  }

  /// Get total donations for a charity
  Future<double> getTotalDonationsForCharity(String charityId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('amount')
          .eq('charity_id', charityId)
          .eq('status', 'success');

      double total = 0;
      for (var donation in response as List) {
        total += double.tryParse(donation['amount'].toString()) ?? 0;
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total donations: $e');
    }
  }
}

class UserProfileRepository {
  final SupabaseClient _supabase;

  UserProfileRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return UserProfile.fromJson(response);
    } catch (e) {
      return null; // Profile doesn't exist yet
    }
  }

  /// Create user profile
  Future<UserProfile> createUserProfile({
    required String id,
    String? name,
    String? email,
    String? role,
    String? language,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .insert({
            'id': id,
            'name': name,
            'email': email,
            'role': role ?? 'user',
            'language': language ?? 'en',
          })
          .select()
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? role,
    String? language,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) {
        updateData['name'] = name;
      }
      if (email != null) {
        updateData['email'] = email;
      }
      if (role != null) {
        updateData['role'] = role;
      }
      if (language != null) {
        updateData['language'] = language;
      }

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}

/// Beneficiary Details Repository
class BeneficiaryDetailsRepository {
  final SupabaseClient _supabase;

  BeneficiaryDetailsRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch beneficiary details by user ID
  Future<BeneficiaryDetails?> getBeneficiaryDetails(String userId) async {
    try {
      final response = await _supabase
          .from('beneficiary_details')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response != null ? BeneficiaryDetails.fromJson(response) : null;
    } catch (e) {
      print('[BeneficiaryDetailsRepository] Error fetching details: $e');
      return null;
    }
  }

  /// Create beneficiary details
  Future<BeneficiaryDetails> createBeneficiaryDetails({
    required String userId,
    required String fullName,
    required String nic,
    required String address,
    required String bankAccountHolderName,
    required String bankAccountNumber,
    required String bankName,
    required String bankCode,
  }) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from('beneficiary_details')
          .insert({
            'user_id': userId,
            'full_name': fullName,
            'nic': nic,
            'address': address,
            'bank_account_holder_name': bankAccountHolderName,
            'bank_account_number': bankAccountNumber,
            'bank_name': bankName,
            'bank_code': bankCode,
            'profile_completed': true,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select()
          .single();
      return BeneficiaryDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create beneficiary details: $e');
    }
  }

  /// Update beneficiary details
  Future<BeneficiaryDetails> updateBeneficiaryDetails({
    required String userId,
    String? fullName,
    String? nic,
    String? address,
    String? bankAccountHolderName,
    String? bankAccountNumber,
    String? bankName,
    String? bankCode,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (nic != null) updateData['nic'] = nic;
      if (address != null) updateData['address'] = address;
      if (bankAccountHolderName != null) {
        updateData['bank_account_holder_name'] = bankAccountHolderName;
      }
      if (bankAccountNumber != null) {
        updateData['bank_account_number'] = bankAccountNumber;
      }
      if (bankName != null) updateData['bank_name'] = bankName;
      if (bankCode != null) updateData['bank_code'] = bankCode;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('beneficiary_details')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();
      return BeneficiaryDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update beneficiary details: $e');
    }
  }
}

/// Beneficiary Campaign Repository
class BeneficiaryCampaignRepository {
  final SupabaseClient _supabase;

  BeneficiaryCampaignRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch all beneficiary campaigns
  Future<List<BeneficiaryCampaign>> getAllBeneficiaryCampaigns() async {
    try {
      final response = await _supabase
          .from('beneficiary_campaigns')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => BeneficiaryCampaign.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch beneficiary campaigns: $e');
    }
  }

  /// Fetch beneficiary campaigns by user ID
  Future<List<BeneficiaryCampaign>> getBeneficiaryCampaignsByUserId(
      String userId) async {
    try {
      final response = await _supabase
          .from('beneficiary_campaigns')
          .select()
          .eq('beneficiary_user_id', userId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => BeneficiaryCampaign.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch beneficiary campaigns: $e');
    }
  }

  /// Fetch campaign by ID
  Future<BeneficiaryCampaign?> getBeneficiaryCampaignById(
      String campaignId) async {
    try {
      final response = await _supabase
          .from('beneficiary_campaigns')
          .select()
          .eq('id', campaignId)
          .maybeSingle();
      return response != null ? BeneficiaryCampaign.fromJson(response) : null;
    } catch (e) {
      print('[BeneficiaryCampaignRepository] Error fetching campaign: $e');
      return null;
    }
  }

  /// Create beneficiary campaign
  Future<BeneficiaryCampaign> createBeneficiaryCampaign({
    required String beneficiaryUserId,
    required String fullName,
    required String title,
    required String description,
    required double targetAmount,
    String? imageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from('beneficiary_campaigns')
          .insert({
            'beneficiary_user_id': beneficiaryUserId,
            'full_name': fullName,
            'title': title,
            'description': description,
            'target_amount': targetAmount,
            'raised_amount': 0,
            'image_url': imageUrl,
            'status': 'active',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select()
          .single();
      return BeneficiaryCampaign.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create beneficiary campaign: $e');
    }
  }

  /// Update beneficiary campaign
  Future<BeneficiaryCampaign> updateBeneficiaryCampaign({
    required String campaignId,
    String? title,
    String? description,
    double? targetAmount,
    String? imageUrl,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (targetAmount != null) updateData['target_amount'] = targetAmount;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (status != null) updateData['status'] = status;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('beneficiary_campaigns')
          .update(updateData)
          .eq('id', campaignId)
          .select()
          .single();
      return BeneficiaryCampaign.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update beneficiary campaign: $e');
    }
  }

  /// Delete beneficiary campaign
  Future<void> deleteBeneficiaryCampaign(String campaignId) async {
    try {
      await _supabase
          .from('beneficiary_campaigns')
          .delete()
          .eq('id', campaignId);
    } catch (e) {
      throw Exception('Failed to delete beneficiary campaign: $e');
    }
  }
}
