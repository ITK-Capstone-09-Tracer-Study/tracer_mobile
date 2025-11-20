import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider untuk handle authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _loginEmail; // Store email from login

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get loginEmail => _loginEmail;

  /// Initialize - Check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isAuthenticated();
      
      // If authenticated, fetch current user profile
      if (_isAuthenticated) {
        await fetchCurrentUser();
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch current user profile
  Future<bool> fetchCurrentUser() async {
    try {
      debugPrint('🔍 Fetching current user profile...');
      final response = await _authService.getCurrentUser();
      
      debugPrint('📦 User profile response: success=${response.success}, data=${response.data}');
      
      if (response.success && response.data != null) {
        _currentUser = UserModel.fromJson(response.data!);
        debugPrint('✅ User profile loaded: ${_currentUser?.name} (${_currentUser?.role})');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to fetch user profile';
        debugPrint('❌ Failed to fetch user profile: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch user profile: $e';
      debugPrint('❌ Exception fetching user profile: $e');
      return false;
    }
  }

  /// Login user
  /// Returns true if login successful, false otherwise
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        // Store login email for reference
        _loginEmail = email;
        
        // Check if response has user data
        if (response.data!.containsKey('user') && response.data!['user'] != null) {
          final userData = response.data!['user'] as Map<String, dynamic>;
          _currentUser = UserModel.fromJson(userData);
          debugPrint('✅ User data from login response: ${_currentUser?.name}');
        } else {
          // If no user data in response, fetch it separately
          _currentUser = null;
          debugPrint('⚠️ No user data in login response, will fetch separately');
        }
        
        _isAuthenticated = true;
        _errorMessage = null;
        
        // Fetch user profile if not included in login response
        if (_currentUser == null) {
          debugPrint('🔄 Fetching user profile after login...');
          final fetchSuccess = await fetchCurrentUser();
          if (!fetchSuccess) {
            debugPrint('⚠️ Failed to fetch user profile, but login was successful');
            // Create minimal user from login email
            _createMinimalUserFromEmail(email);
          }
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        _isAuthenticated = false;
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isAuthenticated = false;
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🚪 Logging out user: ${_currentUser?.email}');
      
      await _authService.logout();
      
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
      _loginEmail = null;
      
      debugPrint('✅ Logout successful, state cleared');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      _errorMessage = 'Failed to logout: $e';
      
      // Even if API call fails, clear local state
      _currentUser = null;
      _isAuthenticated = false;
      _loginEmail = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create minimal user data from email when API doesn't provide user profile
  void _createMinimalUserFromEmail(String email) {
    debugPrint('📝 Creating minimal user from email: $email');
    
    // Determine role based on email pattern
    String role = 'admin'; // Default
    if (email.contains('tracerstudy')) {
      role = 'admin';
    } else if (email.contains('tracer')) {
      role = 'tracer_team';
    } else if (email.contains('prodi') || email.contains('major')) {
      role = 'major_team';
    }
    
    // Extract name from email
    final namePart = email.split('@')[0];
    final name = namePart.replaceAll('.', ' ').replaceAll('_', ' ').toUpperCase();
    
    _currentUser = UserModel(
      id: 0, // Temporary ID
      name: name,
      email: email,
      role: role,
      unitType: 'institutional',
      nikNip: '',
      phoneNumber: '',
    );
    
    debugPrint('✅ Created minimal user: ${_currentUser?.name} (${_currentUser?.role})');
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
