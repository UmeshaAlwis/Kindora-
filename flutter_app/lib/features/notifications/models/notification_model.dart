class AppNotification {
  final String id;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      type: json['type']?.toString() ?? 'generic',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

