import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kindora/models/wallet_model.dart';
import 'package:kindora/services/wallet_service.dart';

// Wallet service provider
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

// Wallet balance provider (single read)
final walletBalanceProvider = FutureProvider<double>((ref) async {
  final walletService = ref.watch(walletServiceProvider);
  return await walletService.getWalletBalance();
});

// Wallet details provider
final walletDetailsProvider = FutureProvider<Wallet>((ref) async {
  final walletService = ref.watch(walletServiceProvider);
  return await walletService.getWalletDetails();
});

// Wallet transactions provider
final walletTransactionsProvider =
    FutureProvider.family<List<WalletTransaction>, ({int page, int limit})>(
  (ref, params) async {
    final walletService = ref.watch(walletServiceProvider);
    return await walletService.getWalletTransactions(
      page: params.page,
      limit: params.limit,
    );
  },
);

// State notifier for wallet operations
class WalletNotifier extends StateNotifier<AsyncValue<Wallet>> {
  WalletNotifier(this._walletService) : super(const AsyncValue.loading());

  final WalletService _walletService;

  /// Refresh wallet balance
  Future<void> refreshBalance() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _walletService.getWalletDetails());
  }

  /// Top-up wallet
  Future<void> topUp(double amount, String paymentMethodId) async {
    try {
      await _walletService.topUpWallet(
        amount: amount,
        paymentMethodId: paymentMethodId,
      );
      await refreshBalance();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Process wallet payment
  Future<void> processPayment({
    required double amount,
    required String campaignId,
    required String donorName,
    required String donorEmail,
  }) async {
    try {
      await _walletService.processWalletPayment(
        amount: amount,
        campaignId: campaignId,
        donorName: donorName,
        donorEmail: donorEmail,
      );
      await refreshBalance();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Wallet state provider
final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<Wallet>>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  return WalletNotifier(walletService);
});
