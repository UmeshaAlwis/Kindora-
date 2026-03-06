import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_profile_model.dart';

class ProfileRepository {
  final String baseUrl;
  final String? Function()? getToken;

  ProfileRepository({
    this.baseUrl = 'http://localhost:3000',
    this.getToken,
  });

  String get _authorizationHeader {
    final token = getToken?.call() ?? 'mock_token';
    return 'Bearer $token';
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Authorization': _authorizationHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UserProfile.fromJson(json['data'] ?? json);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPreferences> getUserPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/preferences'),
        headers: {
          'Authorization': _authorizationHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UserPreferences.fromJson(json['data'] ?? json);
      } else {
        throw Exception('Failed to load preferences');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Authorization': _authorizationHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UserProfile.fromJson(json['data'] ?? json);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPreferences> updateUserPreferences(
      UserPreferences preferences) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/preferences'),
        headers: {
          'Authorization': _authorizationHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(preferences.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UserPreferences.fromJson(json['data'] ?? json);
      } else {
        throw Exception('Failed to update preferences');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile> uploadProfilePicture(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/users/profile/picture'),
      );

      request.headers['Authorization'] = _authorizationHeader;
      request.files.add(
        await http.MultipartFile.fromPath('picture', imagePath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final json = jsonDecode(await response.stream.bytesToString());
        return UserProfile.fromJson(json['data'] ?? json);
      } else {
        throw Exception('Failed to upload profile picture');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: {
          'Authorization': _authorizationHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/account'),
        headers: {
          'Authorization': _authorizationHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      rethrow;
    }
  }
}
