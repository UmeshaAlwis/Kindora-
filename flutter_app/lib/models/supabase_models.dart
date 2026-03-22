import 'package:equatable/equatable.dart';

/// Campaign model matching Supabase schema
class Campaign extends Equatable {
  final String id;
  final String title;
  final String? campaignerName;
  final String? category;
  final String? campaignCategory;
  final double? targetAmount;
  final DateTime createdAt;
  final String? image;
  final String? description;
  final double? raisedAmount;
  final DateTime? endDate;

  const Campaign({
    required this.id,
    required this.title,
    this.campaignerName,
    this.category,
    this.campaignCategory,
    this.targetAmount,
    required this.createdAt,
    this.image,
    this.description,
    this.raisedAmount,
    this.endDate,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      campaignerName: json['campaigner_name'],
      category: json['category'],
      campaignCategory: json['campaign_category'],
      targetAmount: json['target_amount'] != null
          ? double.tryParse(json['target_amount'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      image: json['image_url'],
      description: json['description'],
      raisedAmount: json['raised_amount'] != null
          ? double.tryParse(json['raised_amount'].toString())
          : 0.0,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'campaigner_name': campaignerName,
      'category': category,
      'campaign_category': campaignCategory,
      'target_amount': targetAmount,
      'created_at': createdAt.toIso8601String(),
      'image': image,
      'description': description,
      'raised_amount': raisedAmount,
      'end_date': endDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        campaignerName,
        category,
        campaignCategory,
        targetAmount,
        createdAt,
        image,
        description,
        raisedAmount,
        endDate,
      ];
}

/// Charity model matching Supabase schema
class Charity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? category;
  final double amountRaised;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Charity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    this.amountRaised = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Charity.fromJson(Map<String, dynamic> json) {
    return Charity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      category: json['category'],
      amountRaised: json['amount_raised'] != null
          ? double.tryParse(json['amount_raised'].toString()) ?? 0
          : 0,
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
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'amount_raised': amountRaised,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        category,
        amountRaised,
        createdAt,
        updatedAt,
      ];
}

/// Donation model matching Supabase schema
class Donation extends Equatable {
  final String id;
  final String? userId;
  final String? charityId;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Donation({
    required this.id,
    this.userId,
    this.charityId,
    required this.amount,
    this.currency = 'LKR',
    this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] ?? '',
      userId: json['user_id'],
      charityId: json['charity_id'],
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString()) ?? 0
          : 0,
      currency: json['currency'] ?? 'LKR',
      paymentMethod: json['payment_method'],
      status: json['status'] ?? 'pending',
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
      'id': id,
      'user_id': userId,
      'charity_id': charityId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        charityId,
        amount,
        currency,
        paymentMethod,
        status,
        createdAt,
        updatedAt,
      ];
}

/// User profile model matching Supabase schema
class UserProfile extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String? role;
  final String? language;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.language,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'],
      role: json['role'],
      language: json['language'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'language': language,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, email, role, language, createdAt];
}

/// Merchandise model matching Supabase schema
class Merchandise extends Equatable {
  final String id;
  final String? name;
  final double? price;
  final int? stock;
  final String? imageUrl;
  final DateTime createdAt;

  const Merchandise({
    required this.id,
    this.name,
    this.price,
    this.stock,
    this.imageUrl,
    required this.createdAt,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      id: json['id'] ?? '',
      name: json['name'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      stock: json['stock'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, price, stock, imageUrl, createdAt];
}

/// Message model matching Supabase schema
class Message extends Equatable {
  final String id;
  final String? senderId;
  final String? receiverId;
  final String? content;
  final DateTime createdAt;

  const Message({
    required this.id,
    this.senderId,
    this.receiverId,
    this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, senderId, receiverId, content, createdAt];
}

/// Beneficiary Profile Details Model
class BeneficiaryDetails extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String nic;
  final String address;
  final String bankAccountHolderName;
  final String bankAccountNumber;
  final String bankName;
  final String bankCode;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BeneficiaryDetails({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.nic,
    required this.address,
    required this.bankAccountHolderName,
    required this.bankAccountNumber,
    required this.bankName,
    required this.bankCode,
    this.profileCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BeneficiaryDetails.fromJson(Map<String, dynamic> json) {
    return BeneficiaryDetails(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      nic: json['nic'] ?? '',
      address: json['address'] ?? '',
      bankAccountHolderName: json['bank_account_holder_name'] ?? '',
      bankAccountNumber: json['bank_account_number'] ?? '',
      bankName: json['bank_name'] ?? '',
      bankCode: json['bank_code'] ?? '',
      profileCompleted: json['profile_completed'] ?? false,
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
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'nic': nic,
      'address': address,
      'bank_account_holder_name': bankAccountHolderName,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'bank_code': bankCode,
      'profile_completed': profileCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        nic,
        address,
        bankAccountHolderName,
        bankAccountNumber,
        bankName,
        bankCode,
        profileCompleted,
        createdAt,
        updatedAt,
      ];
}

/// Beneficiary Campaign Model (GoFundMe style)
class BeneficiaryCampaign extends Equatable {
  final String id;
  final String beneficiaryUserId;
  final String fullName;
  final String title;
  final String description;
  final double targetAmount;
  final double raisedAmount;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BeneficiaryCampaign({
    required this.id,
    required this.beneficiaryUserId,
    required this.fullName,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.raisedAmount = 0,
    this.imageUrl,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BeneficiaryCampaign.fromJson(Map<String, dynamic> json) {
    return BeneficiaryCampaign(
      id: json['id'] ?? '',
      beneficiaryUserId: json['beneficiary_user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetAmount: json['target_amount'] != null
          ? double.tryParse(json['target_amount'].toString()) ?? 0
          : 0,
      raisedAmount: json['raised_amount'] != null
          ? double.tryParse(json['raised_amount'].toString()) ?? 0
          : 0,
      imageUrl: json['image_url'],
      status: json['status'] ?? 'active',
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
      'id': id,
      'beneficiary_user_id': beneficiaryUserId,
      'full_name': fullName,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'raised_amount': raisedAmount,
      'image_url': imageUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        beneficiaryUserId,
        fullName,
        title,
        description,
        targetAmount,
        raisedAmount,
        imageUrl,
        status,
        createdAt,
        updatedAt,
      ];
}
