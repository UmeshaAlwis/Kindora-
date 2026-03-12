import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String walletId;
  final String userId;
  final double balance;
  final double totalRecharged;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.walletId,
    required this.userId,
    required this.balance,
    required this.totalRecharged,
    required this.totalSpent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['wallet_id'] ?? '',
      userId: json['user_id'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalRecharged: (json['total_recharged'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'user_id': userId,
      'balance': balance,
      'total_recharged': totalRecharged,
      'total_spent': totalSpent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for state updates
  Wallet copyWith({
    String? walletId,
    String? userId,
    double? balance,
    double? totalRecharged,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      totalRecharged: totalRecharged ?? this.totalRecharged,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        walletId,
        userId,
        balance,
        totalRecharged,
        totalSpent,
        createdAt,
        updatedAt,
      ];
}

class WalletTransaction extends Equatable {
  final String transactionId;
  final String walletId;
  final String type; // 'debit' or 'credit'
  final double amount;
  final String? referenceId;
  final String description;
  final DateTime timestamp;

  const WalletTransaction({
    required this.transactionId,
    required this.walletId,
    required this.type,
    required this.amount,
    this.referenceId,
    required this.description,
    required this.timestamp,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      transactionId: json['transaction_id'] ?? '',
      walletId: json['wallet_id'] ?? '',
      type: json['type'] ?? 'debit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      referenceId: json['reference_id'],
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'wallet_id': walletId,
      'type': type,
      'amount': amount,
      'reference_id': referenceId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        transactionId,
        walletId,
        type,
        amount,
        referenceId,
        description,
        timestamp,
      ];
}
