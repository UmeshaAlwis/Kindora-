class PaymentModel {
  final String id;
  final String campaignId;
  final String? userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String donationType;
  final String? recurringFrequency;
  final String status;
  final String? message;
  final bool isAnonymous;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.campaignId,
    this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.donationType,
    this.recurringFrequency,
    required this.status,
    this.message,
    required this.isAnonymous,
    this.transactionId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create PaymentModel from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      campaignId: json['campaign_id'] as String,
      userId: json['user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      paymentMethod: json['payment_method'] as String,
      donationType: json['donation_type'] as String? ?? 'one-time',
      recurringFrequency: json['recurring_frequency'] as String?,
      status: json['status'] as String,
      message: json['message'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      transactionId: json['transaction_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// Convert PaymentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'donation_type': donationType,
      'recurring_frequency': recurringFrequency,
      'status': status,
      'message': message,
      'is_anonymous': isAnonymous,
      'transaction_id': transactionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with method for creating modified copies
  PaymentModel copyWith({
    String? id,
    String? campaignId,
    String? userId,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? donationType,
    String? recurringFrequency,
    String? status,
    String? message,
    bool? isAnonymous,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      donationType: donationType ?? this.donationType,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      status: status ?? this.status,
      message: message ?? this.message,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, campaignId: $campaignId, amount: $amount, '
        'paymentMethod: $paymentMethod, status: $status)';
  }
}
