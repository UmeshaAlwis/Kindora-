import 'package:equatable/equatable.dart';

class Donation extends Equatable {
  final String id;
  final String charityName;
  final String charityId;
  final double amount;
  final DateTime date;
  final String status; // 'success', 'failed', 'pending'
  final String? receiptUrl;
  final String? receiptId;
  final String category;

  const Donation({
    required this.id,
    required this.charityName,
    required this.charityId,
    required this.amount,
    required this.date,
    required this.status,
    this.receiptUrl,
    this.receiptId,
    required this.category,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      charityName: json['charityName'] as String,
      charityId: json['charityId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      receiptUrl: json['receiptUrl'] as String?,
      receiptId: json['receiptId'] as String?,
      category: json['category'] as String? ?? 'Other',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'charityName': charityName,
        'charityId': charityId,
        'amount': amount,
        'date': date.toIso8601String(),
        'status': status,
        'receiptUrl': receiptUrl,
        'receiptId': receiptId,
        'category': category,
      };

  @override
  List<Object?> get props => [
        id,
        charityName,
        charityId,
        amount,
        date,
        status,
        receiptUrl,
        receiptId,
        category,
      ];
}

class RecurringDonation extends Equatable {
  final String id;
  final String charityName;
  final String charityId;
  final double amountPerCycle;
  final String frequency; // 'weekly', 'monthly', 'yearly'
  final DateTime startDate;
  final DateTime? nextDueDate;
  final bool active;
  final String category;

  const RecurringDonation({
    required this.id,
    required this.charityName,
    required this.charityId,
    required this.amountPerCycle,
    required this.frequency,
    required this.startDate,
    this.nextDueDate,
    required this.active,
    required this.category,
  });

  factory RecurringDonation.fromJson(Map<String, dynamic> json) {
    return RecurringDonation(
      id: json['id'] as String,
      charityName: json['charityName'] as String,
      charityId: json['charityId'] as String,
      amountPerCycle: (json['amountPerCycle'] as num).toDouble(),
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : null,
      active: json['active'] as bool? ?? true,
      category: json['category'] as String? ?? 'Other',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'charityName': charityName,
        'charityId': charityId,
        'amountPerCycle': amountPerCycle,
        'frequency': frequency,
        'startDate': startDate.toIso8601String(),
        'nextDueDate': nextDueDate?.toIso8601String(),
        'active': active,
        'category': category,
      };

  @override
  List<Object?> get props => [
        id,
        charityName,
        charityId,
        amountPerCycle,
        frequency,
        startDate,
        nextDueDate,
        active,
        category,
      ];
}

class DonationSummary extends Equatable {
  final double totalAmountDonated;
  final int totalCampaignsSupported;
  final int kindPointsEarned;

  const DonationSummary({
    required this.totalAmountDonated,
    required this.totalCampaignsSupported,
    required this.kindPointsEarned,
  });

  factory DonationSummary.fromJson(Map<String, dynamic> json) {
    return DonationSummary(
      totalAmountDonated: (json['totalAmountDonated'] as num).toDouble(),
      totalCampaignsSupported: json['totalCampaignsSupported'] as int,
      kindPointsEarned: json['kindPointsEarned'] as int,
    );
  }

  @override
  List<Object?> get props =>
      [totalAmountDonated, totalCampaignsSupported, kindPointsEarned];
}

class CategoryBreakdown extends Equatable {
  final String category;
  final double amount;
  final int count;

  const CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.count,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  @override
  List<Object?> get props => [category, amount, count];
}
