class NewsModel {
  final String title;
  final String updateText;
  final String imageUrl;
  final String status;
  final String date;

  // Added 'const' here to fix the build error
  const NewsModel({
    required this.title,
    required this.updateText,
    required this.imageUrl,
    required this.status,
    required this.date,
  });
}
// final model update