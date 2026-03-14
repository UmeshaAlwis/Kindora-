import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/supabase_repositories.dart';
import '../models/supabase_models.dart';

// Repository providers
final campaignRepositoryProvider = Provider((ref) {
  return CampaignRepository();
});

final charityRepositoryProvider = Provider((ref) {
  return CharityRepository();
});

final donationRepositoryProvider = Provider((ref) {
  return DonationRepository();
});

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository();
});

final merchandiseRepositoryProvider = Provider((ref) {
  return MerchandiseRepository();
});

final productReviewRepositoryProvider = Provider((ref) {
  return ProductReviewRepository();
});

// Campaign providers
final allCampaignsProvider = FutureProvider((ref) async {
  print('[allCampaignsProvider] Starting to fetch campaigns...');
  try {
    final repository = ref.watch(campaignRepositoryProvider);
    final campaigns = await repository.getAllCampaigns();
    print(
        '[allCampaignsProvider] Successfully fetched ${campaigns.length} campaigns');
    return campaigns;
  } catch (error, stackTrace) {
    print('[allCampaignsProvider] ERROR: $error');
    print('[allCampaignsProvider] STACK: $stackTrace');
    rethrow;
  }
});

final campaignByIdProvider =
    FutureProvider.family<Campaign?, String>((ref, campaignId) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getCampaignById(campaignId);
});

final campaignsByCategoryProvider =
    FutureProvider.family<List<Campaign>, String>((ref, category) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getCampaignsByCategory(category);
});

// Charity providers
final allCharitiesProvider = FutureProvider((ref) async {
  final repository = ref.watch(charityRepositoryProvider);
  return repository.getAllCharities();
});

final charityByIdProvider =
    FutureProvider.family<Charity?, String>((ref, charityId) async {
  final repository = ref.watch(charityRepositoryProvider);
  return repository.getCharityById(charityId);
});

final charitiesByCategoryProvider =
    FutureProvider.family<List<Charity>, String>((ref, category) async {
  final repository = ref.watch(charityRepositoryProvider);
  return repository.getCharitiesByCategory(category);
});

// Donation providers
final allDonationsProvider = FutureProvider((ref) async {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getAllDonations();
});

final donationsByUserProvider =
    FutureProvider.family<List<Donation>, String>((ref, userId) async {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getDonationsByUserId(userId);
});

final donationsByCharityProvider =
    FutureProvider.family<List<Donation>, String>((ref, charityId) async {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getDonationsByCharityId(charityId);
});

final totalDonationsForCharityProvider =
    FutureProvider.family<double, String>((ref, charityId) async {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getTotalDonationsForCharity(charityId);
});

// User Profile providers
final userProfileProvider =
    FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.getUserProfile(userId);
});

// State notifier for cache invalidation
final campaignRefreshProvider = StateProvider((ref) => DateTime.now());
final charityRefreshProvider = StateProvider((ref) => DateTime.now());
final donationRefreshProvider = StateProvider((ref) => DateTime.now());

// Merchandise providers
final allMerchandiseProvider = FutureProvider((ref) async {
  print('[allMerchandiseProvider] Starting to fetch merchandise...');
  try {
    final repository = ref.watch(merchandiseRepositoryProvider);
    final products = await repository.getAllMerchandise();
    print(
        '[allMerchandiseProvider] Successfully fetched ${products.length} products');
    return products;
  } catch (error, stackTrace) {
    print('[allMerchandiseProvider] ERROR: $error');
    print('[allMerchandiseProvider] STACK: $stackTrace');
    rethrow;
  }
});

final merchandiseByIdProvider =
    FutureProvider.family<Merchandise?, String>((ref, productId) async {
  final repository = ref.watch(merchandiseRepositoryProvider);
  return repository.getMerchandiseById(productId);
});

final merchandiseByCategoryProvider =
    FutureProvider.family<List<Merchandise>, String>((ref, category) async {
  final repository = ref.watch(merchandiseRepositoryProvider);
  return repository.getMerchandiseByCategory(category);
});

final searchMerchandiseProvider =
    FutureProvider.family<List<Merchandise>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final repository = ref.watch(merchandiseRepositoryProvider);
  return repository.searchMerchandise(query);
});

final bestsellersProvider = FutureProvider((ref) async {
  final repository = ref.watch(merchandiseRepositoryProvider);
  return repository.getBestsellers(limit: 6);
});

// Product Review providers
final productReviewsProvider =
    FutureProvider.family<List<ProductReview>, String>((ref, productId) async {
  final repository = ref.watch(productReviewRepositoryProvider);
  return repository.getProductReviews(productId);
});

final reviewByIdProvider =
    FutureProvider.family<ProductReview?, String>((ref, reviewId) async {
  final repository = ref.watch(productReviewRepositoryProvider);
  return repository.getReviewById(reviewId);
});

// State notifiers for user interactions
final merchandiseRefreshProvider = StateProvider((ref) => DateTime.now());
final cartItemsProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);
