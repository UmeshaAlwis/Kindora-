import 'package:flutter/foundation.dart';
import 'user_profile_model.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository? _repository;
  
  UserProfile? _profile;
  UserPreferences? _preferences;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  UserProfile? get userProfile => _profile;
  UserProfile? get profile => _profile;
  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository!.getUserProfile();
      await loadUserPreferences();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPreferences() async {
    try {
      _preferences = await _repository!.getUserPreferences();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProfileData() async {
    await loadUserProfile();
    await loadUserPreferences();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository!.updateUserProfile(profile);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await _repository!.updateUserPreferences(preferences);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> uploadProfilePicture(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository!.uploadProfilePicture(imagePath);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository!.logout();
      _profile = null;
      _preferences = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository!.deleteAccount();
      _profile = null;
      _preferences = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }
}
