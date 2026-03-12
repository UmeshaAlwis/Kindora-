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
