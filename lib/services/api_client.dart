import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API Client untuk handle semua HTTP request ke backend
/// Base URL: http://localhost:8000/api (or 10.0.2.2 for Android emulator)
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late Dio _dio;
  String? _authToken;
  
  // Base URL API - automatically use correct localhost for platform
  static String get baseUrl {
    // For Android emulator, localhost doesn't work, use 10.0.2.2
    // For iOS simulator and desktop, use localhost
    if (kIsWeb) {
      return 'http://localhost:8000/api'; // Web
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:8000/api'; // Android Emulator
        } else {
          return 'http://localhost:8000/api'; // iOS/Desktop
        }
      } catch (e) {
        return 'http://localhost:8000/api'; // Fallback
      }
    }
  }
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authorization token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        if (kDebugMode) {
          debugPrint('🌐 REQUEST: ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          debugPrint('   Message: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }
  
  /// Get Dio instance
  Dio get dio => _dio;
  
  /// Set authentication token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  /// Get authentication token
  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }
  
  /// Remove authentication token
  Future<void> removeAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null;
  }
  
  /// Initialize token from storage (call this on app start)
  Future<void> initialize() async {
    await getAuthToken();
  }
}
