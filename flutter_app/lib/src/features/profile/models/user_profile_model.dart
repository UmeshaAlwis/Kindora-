import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isVerified;
  final double totalDonations;
  final int totalCampaignsSupported;
  final int kindPoints;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.isVerified,
    required this.totalDonations,
    required this.totalCampaignsSupported,
    required this.kindPoints,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      isVerified: json['isVerified'] as bool,
      totalDonations: (json['totalDonations'] as num).toDouble(),
      totalCampaignsSupported: json['totalCampaignsSupported'] as int,
      kindPoints: json['kindPoints'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'totalDonations': totalDonations,
      'totalCampaignsSupported': totalCampaignsSupported,
      'kindPoints': kindPoints,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isVerified,
    double? totalDonations,
    int? totalCampaignsSupported,
    int? kindPoints,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      totalDonations: totalDonations ?? this.totalDonations,
      totalCampaignsSupported: totalCampaignsSupported ?? this.totalCampaignsSupported,
      kindPoints: kindPoints ?? this.kindPoints,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phoneNumber,
        profileImageUrl,
        isVerified,
        totalDonations,
        totalCampaignsSupported,
        kindPoints,
        createdAt,
        lastUpdatedAt,
        isActive,
      ];
}

class UserPreferences extends Equatable {
  final bool regularDonationEnabled;
  final bool donationReminderEnabled;
  final bool notificationsEnabled;
  final String language;
  final String theme;
  final String currency;

  const UserPreferences({
    required this.regularDonationEnabled,
    required this.donationReminderEnabled,
    required this.notificationsEnabled,
    this.language = 'en',
    this.theme = 'light',
    this.currency = 'USD',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      regularDonationEnabled: json['regularDonationEnabled'] as bool? ?? false,
      donationReminderEnabled: json['donationReminderEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
      theme: json['theme'] as String? ?? 'light',
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regularDonationEnabled': regularDonationEnabled,
      'donationReminderEnabled': donationReminderEnabled,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
      'theme': theme,
      'currency': currency,
    };
  }

  UserPreferences copyWith({
    bool? regularDonationEnabled,
    bool? donationReminderEnabled,
    bool? notificationsEnabled,
    String? language,
    String? theme,
    String? currency,
  }) {
    return UserPreferences(
      regularDonationEnabled: regularDonationEnabled ?? this.regularDonationEnabled,
      donationReminderEnabled: donationReminderEnabled ?? this.donationReminderEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
        regularDonationEnabled,
        donationReminderEnabled,
        notificationsEnabled,
        language,
        theme,
        currency,
      ];
}
