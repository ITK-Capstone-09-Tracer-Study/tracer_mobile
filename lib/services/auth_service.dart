import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Service untuk handle Authentication API
/// Endpoint: /auth/*
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Login user
  /// POST /auth/login
  /// Body: { "email": "string", "password": "string" }
  /// Response: { "token": "string", "user": UserTransformer }
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Attempting login for: $email');
        debugPrint('🌐 Base URL: ${ApiClient.baseUrl}');
      }
      
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (kDebugMode) {
        debugPrint('✅ Login response: ${response.statusCode}');
        debugPrint('📦 Response data: ${response.data}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        if (kDebugMode) {
          debugPrint('📦 Full response structure: $data');
        }
        
        // Handle different response formats
        String? token;
        
        // Check if response has 'token' field directly
        if (data.containsKey('token')) {
          token = data['token'] as String?;
        }
        
        // Check if response has 'data' wrapper
        if (data.containsKey('data') && data['data'] is Map) {
          final innerData = data['data'] as Map<String, dynamic>;
          token ??= innerData['token'] as String?;
        }
        
        if (token == null || token.isEmpty) {
          return ApiResponse.error(
            message: 'Login successful but no token received',
            statusCode: response.statusCode,
          );
        }
        
        // Save token
        await _apiClient.setAuthToken(token);
        
        if (kDebugMode) {
          debugPrint('✅ Token saved successfully: ${token.substring(0, 20)}...');
        }
        
        // Return the full response data
        return ApiResponse.success(
          data: data,
          message: data['message'] as String? ?? 'Login successful',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Login failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException: ${e.type}');
        debugPrint('❌ Status: ${e.response?.statusCode}');
        debugPrint('❌ Response: ${e.response?.data}');
        debugPrint('❌ Message: ${e.message}');
      }
      
      if (e.response?.statusCode == 401) {
        return ApiResponse.error(
          message: 'Invalid email or password',
          statusCode: 401,
        );
      }
      
      // Handle network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.error(
          message: 'Connection timeout. Please check your network connection.',
        );
      }
      
      if (e.type == DioExceptionType.connectionError) {
        return ApiResponse.error(
          message: 'Cannot connect to server. Please check if the API is running on ${ApiClient.baseUrl}',
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Login failed',
        errors: e.response?.data['errors'] as Map<String, dynamic>?,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error: $e');
      }
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Logout user
  /// POST /auth/logout
  Future<ApiResponse<void>> logout() async {
    try {
      if (kDebugMode) {
        debugPrint('🚪 Calling logout API...');
      }
      
      final response = await _apiClient.dio.post('/auth/logout');

      if (kDebugMode) {
        debugPrint('📥 Logout response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        // Remove token
        await _apiClient.removeAuthToken();
        
        if (kDebugMode) {
          debugPrint('✅ Token removed successfully');
        }
        
        return ApiResponse.success(
          data: null,
          message: 'Logout successful',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Logout failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Logout API error: ${e.message}');
      }
      
      // Even if logout fails on server, remove token locally
      await _apiClient.removeAuthToken();
      
      if (kDebugMode) {
        debugPrint('✅ Token removed locally despite API error');
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Logout failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected logout error: $e');
      }
      
      await _apiClient.removeAuthToken();
      
      return ApiResponse.error(
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    return await _apiClient.getAuthToken();
  }

  /// Get current user profile
  /// GET /auth/user
  /// Returns the currently authenticated user's profile
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      if (kDebugMode) {
        debugPrint('👤 Fetching current user profile...');
      }
      
      final response = await _apiClient.dio.get('/auth/user');

      if (kDebugMode) {
        debugPrint('✅ User profile response: ${response.statusCode}');
        debugPrint('📦 Response data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Handle different response formats
        Map<String, dynamic> userData;
        
        // Check if response has 'user' or 'data' wrapper
        if (data.containsKey('user')) {
          userData = data['user'] as Map<String, dynamic>;
        } else if (data.containsKey('data')) {
          userData = data['data'] as Map<String, dynamic>;
        } else {
          // Assume the response itself is the user data
          userData = data;
        }
        
        return ApiResponse.success(
          data: userData,
          message: 'User profile fetched successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch user profile',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException: ${e.type}');
        debugPrint('❌ Status: ${e.response?.statusCode}');
        debugPrint('❌ Response: ${e.response?.data}');
      }
      
      if (e.response?.statusCode == 401) {
        // Token expired or invalid
        await _apiClient.removeAuthToken();
        return ApiResponse.error(
          message: 'Session expired. Please login again.',
          statusCode: 401,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch user profile',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error: $e');
      }
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}
