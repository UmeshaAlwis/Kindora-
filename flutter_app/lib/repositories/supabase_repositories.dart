import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
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

      final response = await dio.post(
        apiUrl,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
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

class MerchandiseRepository {
  final SupabaseClient _supabase;

  MerchandiseRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch all merchandise products
  Future<List<Merchandise>> getAllMerchandise() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return (response as List)
          .map((data) => Merchandise.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch merchandise: $e');
    }
  }

  /// Fetch merchandise by ID
  Future<Merchandise?> getMerchandiseById(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .eq('is_active', true)
          .single();
      return Merchandise.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Fetch merchandise by category
  Future<List<Merchandise>> getMerchandiseByCategory(String category) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return (response as List)
          .map((data) => Merchandise.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch merchandise by category: $e');
    }
  }

  /// Search merchandise by name
  Future<List<Merchandise>> searchMerchandise(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return (response as List)
          .map((data) => Merchandise.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search merchandise: $e');
    }
  }

  /// Fetch bestsellers (products with highest sales or ratings)
  Future<List<Merchandise>> getBestsellers({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('average_rating', ascending: false)
          .order('review_count', ascending: false)
          .limit(limit);
      return (response as List)
          .map((data) => Merchandise.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bestsellers: $e');
    }
  }

  /// Create new merchandise product
  Future<Merchandise> createMerchandise({
    required String name,
    required double price,
    int stock = 0,
    String? imageUrl,
    String? description,
    String? category,
  }) async {
    try {
      final response = await _supabase
          .from('merchandise')
          .insert({
            'name': name,
            'price': price,
            'stock': stock,
            'image_url': imageUrl,
            'description': description,
            'category': category,
            'average_rating': 0.0,
            'review_count': 0,
          })
          .select()
          .single();
      return Merchandise.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create merchandise: $e');
    }
  }

  /// Update merchandise
  Future<Merchandise> updateMerchandise({
    required String productId,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    String? description,
    String? category,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) {
        updateData['name'] = name;
      }
      if (price != null) {
        updateData['price'] = price;
      }
      if (stock != null) {
        updateData['stock'] = stock;
      }
      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }
      if (description != null) {
        updateData['description'] = description;
      }
      if (category != null) {
        updateData['category'] = category;
      }

      final response = await _supabase
          .from('merchandise')
          .update(updateData)
          .eq('id', productId)
          .select()
          .single();
      return Merchandise.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update merchandise: $e');
    }
  }
}

class ProductReviewRepository {
  final SupabaseClient _supabase;

  ProductReviewRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.supabaseClient;

  /// Fetch all reviews for a product
  Future<List<ProductReview>> getProductReviews(String productId) async {
    try {
      final response = await _supabase
          .from('product_reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((data) => ProductReview.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch product reviews: $e');
    }
  }

  /// Fetch review by ID
  Future<ProductReview?> getReviewById(String reviewId) async {
    try {
      final response = await _supabase
          .from('product_reviews')
          .select()
          .eq('id', reviewId)
          .single();
      return ProductReview.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch review: $e');
    }
  }

  /// Create new review
  Future<ProductReview> createReview({
    required String productId,
    String? userId,
    String? reviewerName,
    required double rating,
    String? reviewText,
  }) async {
    try {
      final response = await _supabase
          .from('product_reviews')
          .insert({
            'product_id': productId,
            'user_id': userId,
            'reviewer_name': reviewerName,
            'rating': rating,
            'review_text': reviewText,
          })
          .select()
          .single();
      return ProductReview.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Update review
  Future<ProductReview> updateReview({
    required String reviewId,
    double? rating,
    String? reviewText,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (rating != null) {
        updateData['rating'] = rating;
      }
      if (reviewText != null) {
        updateData['review_text'] = reviewText;
      }

      final response = await _supabase
          .from('product_reviews')
          .update(updateData)
          .eq('id', reviewId)
          .select()
          .single();
      return ProductReview.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _supabase.from('product_reviews').delete().eq('id', reviewId);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
