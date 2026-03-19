import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../config/app_env.dart';
import '../models/feed_post_model.dart';

class FeedService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _authHeaders() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<FeedPost>> getFeedPosts({int page = 1, int limit = 20}) async {
    final user = _auth.currentUser;
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (user != null) {
      final token = await user.getIdToken();
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/feed?page=$page&limit=$limit'),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to fetch feed');
    }

    return (data['data'] as List)
        .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FeedPost> createPost({
    required String content,
    String? mediaUrl,
    String mediaType = 'none',
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppEnv.apiBaseUrl}/feed'),
      headers: headers,
      body: jsonEncode({
        'content': content,
        'media_url': mediaUrl,
        'media_type': mediaType,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 201 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to create post');
    }

    // API create returns raw row; fetch feed again would enrich user name.
    final row = data['data'] as Map<String, dynamic>;
    return FeedPost.fromJson({
      ...row,
      'user_name': 'You',
      'liked_by_me': false,
      'comments_count': 0,
    });
  }

  Future<void> toggleLike(String postId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppEnv.apiBaseUrl}/feed/$postId/like'),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to like post');
    }
  }

  Future<String> uploadMedia(XFile file) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final token = await user.getIdToken();

    final uri = Uri.parse('${AppEnv.apiBaseUrl}/storage/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['folder'] = 'feed';
    request.files.add(await http.MultipartFile.fromPath('image', File(file.path).path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final data = jsonDecode(body);

    if (streamed.statusCode != 200) {
      throw Exception(data['error'] ?? 'Upload failed');
    }

    final url = data['url'] ?? data['data']?['url'];
    if (url == null) throw Exception('Upload returned empty URL');
    return url.toString();
  }
}
