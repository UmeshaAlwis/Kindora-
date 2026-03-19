class FeedPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final String? mediaUrl;
  final String mediaType; // none | image | video
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;
  final DateTime createdAt;

  const FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    this.mediaUrl,
    required this.mediaType,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByMe,
    required this.createdAt,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      userName: (json['user_name'] ?? 'User').toString(),
      userAvatarUrl: json['user_avatar_url']?.toString(),
      content: (json['content'] ?? '').toString(),
      mediaUrl: json['media_url']?.toString(),
      mediaType: (json['media_type'] ?? 'none').toString(),
      likesCount: (json['likes_count'] ?? 0) is int
          ? (json['likes_count'] ?? 0) as int
          : int.tryParse((json['likes_count'] ?? '0').toString()) ?? 0,
      commentsCount: (json['comments_count'] ?? 0) is int
          ? (json['comments_count'] ?? 0) as int
          : int.tryParse((json['comments_count'] ?? '0').toString()) ?? 0,
      likedByMe: json['liked_by_me'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}
