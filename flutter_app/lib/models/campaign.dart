class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
  });

  /// Convert database/map data into Campaign object
  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      goalAmount: (map['goalAmount'] ?? 0).toDouble(),
      raisedAmount: (map['raisedAmount'] ?? 0).toDouble(),
    );
  }

  /// Convert Campaign object to Map (for database saving)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goalAmount': goalAmount,
      'raisedAmount': raisedAmount,
    };
  }
}