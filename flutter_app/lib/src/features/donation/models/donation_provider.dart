import 'package:flutter/material.dart';
import 'donation_model.dart';
import '../repositories/donation_repository.dart';

class DonationDashboardProvider extends ChangeNotifier {
  final DonationRepository repository;

  DonationSummary? _summary;
  List<Donation> _donationHistory = [];
  List<RecurringDonation> _recurringDonations = [];
  List<CategoryBreakdown> _categoryBreakdown = [];

  bool _isLoadingSummary = false;
  bool _isLoadingHistory = false;
  bool _isLoadingRecurring = false;
  bool _isLoadingAnalytics = false;

  String? _errorMessage;

  // Getters
  DonationSummary? get summary => _summary;
  List<Donation> get donationHistory => _donationHistory;
  List<RecurringDonation> get recurringDonations => _recurringDonations;
  List<CategoryBreakdown> get categoryBreakdown => _categoryBreakdown;

  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingRecurring => _isLoadingRecurring;
  bool get isLoadingAnalytics => _isLoadingAnalytics;

  bool get isLoading =>
      _isLoadingSummary ||
      _isLoadingHistory ||
      _isLoadingRecurring ||
      _isLoadingAnalytics;

  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;

  DonationDashboardProvider({DonationRepository? repository})
      : repository = repository ?? DonationRepository();

  // Alias for backward compatibility
  Future<void> fetchDonationSummary() => loadDonationSummary();

  Future<void> loadDonationSummary() async {
    _isLoadingSummary = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await repository.fetchDonationSummary();
    } catch (e) {
      _errorMessage = e.toString();
      _summary = null;
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> loadDonationHistory({int page = 1, int limit = 10}) async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _donationHistory = await repository.fetchDonationHistory(page: page, limit: limit);
    } catch (e) {
      _errorMessage = e.toString();
      _donationHistory = [];
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadRecurringDonations() async {
    _isLoadingRecurring = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recurringDonations = await repository.fetchRecurringDonations();
    } catch (e) {
      _errorMessage = e.toString();
      _recurringDonations = [];
    } finally {
      _isLoadingRecurring = false;
      notifyListeners();
    }
  }

  Future<void> loadCategoryBreakdown() async {
    _isLoadingAnalytics = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categoryBreakdown = await repository.fetchCategoryBreakdown();
    } catch (e) {
      _errorMessage = e.toString();
      _categoryBreakdown = [];
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadDonationSummary(),
      loadDonationHistory(),
      loadRecurringDonations(),
      loadCategoryBreakdown(),
    ]);
  }

  Future<void> cancelRecurringDonation(String donationId) async {
    try {
      await repository.cancelRecurringDonation(donationId);
      _recurringDonations = [
        for (final d in _recurringDonations)
          if (d.id != donationId) d else d.copyWith(active: false),
      ];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> downloadReceipt(String donationId) async {
    try {
      await repository.downloadReceipt(donationId);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

extension RecurringDonationCopyWith on RecurringDonation {
  RecurringDonation copyWith({
    String? id,
    String? charityName,
    String? charityId,
    double? amountPerCycle,
    String? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    bool? active,
    String? category,
  }) {
    return RecurringDonation(
      id: id ?? this.id,
      charityName: charityName ?? this.charityName,
      charityId: charityId ?? this.charityId,
      amountPerCycle: amountPerCycle ?? this.amountPerCycle,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      active: active ?? this.active,
      category: category ?? this.category,
    );
  }
}
