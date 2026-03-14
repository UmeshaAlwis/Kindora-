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
    this.currency = 'USD',
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
      currency: json['currency'] ?? 'USD',
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
  final String? description;
  final String? category;
  final double? averageRating;
  final int? reviewCount;
  final DateTime createdAt;

  const Merchandise({
    required this.id,
    this.name,
    this.price,
    this.stock,
    this.imageUrl,
    this.description,
    this.category,
    this.averageRating = 0.0,
    this.reviewCount = 0,
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
      description: json['description'],
      category: json['category'],
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString()) ?? 0.0
          : 0.0,
      reviewCount: json['review_count'] ?? 0,
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
      'description': description,
      'category': category,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        stock,
        imageUrl,
        description,
        category,
        averageRating,
        reviewCount,
        createdAt,
      ];
}

/// Product Review model for ratings and customer feedback
class ProductReview extends Equatable {
  final String id;
  final String productId;
  final String? userId;
  final String? reviewerName;
  final double rating;
  final String? reviewText;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.productId,
    this.userId,
    this.reviewerName,
    required this.rating,
    this.reviewText,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      userId: json['user_id'],
      reviewerName: json['reviewer_name'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,
      reviewText: json['review_text'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'reviewer_name': reviewerName,
      'rating': rating,
      'review_text': reviewText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [id, productId, userId, reviewerName, rating, reviewText, createdAt];
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
