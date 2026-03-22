String? _sanitizeRemoteUrl(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  // Strip accidental line breaks / whitespace from API or DB
  final cleaned = s.replaceAll(RegExp(r'[\r\n]+'), '');
  if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
    return null;
  }
  return cleaned;
}

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
      userAvatarUrl: _sanitizeRemoteUrl(json['user_avatar_url']),
      content: (json['content'] ?? '').toString(),
      mediaUrl: _sanitizeRemoteUrl(json['media_url']),
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
