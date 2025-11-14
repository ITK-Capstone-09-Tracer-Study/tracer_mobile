import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Service untuk handle User API
/// Endpoint: /{panel}/users
class UserService {
  final ApiClient _apiClient = ApiClient();
  
  /// Panel untuk admin operations
  static const String panel = 'admin';

  /// Get paginated list of users
  /// GET /{panel}/users?page=1&per_page=10
  Future<ApiResponse<PaginatedResponse<UserModel>>> getUsers({
    int page = 1,
    int perPage = 10,
    Map<String, dynamic>? filters,
    String? sort,
    String? include,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (filters != null) {
        filters.forEach((key, value) {
          queryParams['filter[$key]'] = value;
        });
      }
      
      if (sort != null) queryParams['sort'] = sort;
      if (include != null) queryParams['include'] = include;

      final response = await _apiClient.dio.get(
        '/$panel/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final paginatedData = PaginatedResponse<UserModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => UserModel.fromJson(json),
        );
        
        return ApiResponse.success(
          data: paginatedData,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch users',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch users',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get single user by ID
  /// GET /{panel}/users/{id}
  Future<ApiResponse<UserModel>> getUser(int id) async {
    try {
      final response = await _apiClient.dio.get('/$panel/users/$id');

      if (response.statusCode == 200) {
        final userData = response.data['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        
        return ApiResponse.success(
          data: user,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch user',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'User not found',
          statusCode: 404,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch user',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Create new user
  /// POST /{panel}/users
  Future<ApiResponse<UserModel>> createUser({
    required UserModel user,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/$panel/users',
        data: user.toRequestJson(password: password),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['data'] as Map<String, dynamic>;
        final createdUser = UserModel.fromJson(userData);
        
        return ApiResponse.success(
          data: createdUser,
          message: 'User created successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to create user',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return ApiResponse.error(
          message: 'Validation error',
          errors: e.response?.data['errors'] as Map<String, dynamic>?,
          statusCode: 422,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to create user',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update existing user
  /// PUT /{panel}/users/{id}
  Future<ApiResponse<UserModel>> updateUser({
    required int id,
    required UserModel user,
    String? password,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/$panel/users/$id',
        data: user.toRequestJson(password: password),
      );

      if (response.statusCode == 200) {
        final userData = response.data['data'] as Map<String, dynamic>;
        final updatedUser = UserModel.fromJson(userData);
        
        return ApiResponse.success(
          data: updatedUser,
          message: 'User updated successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to update user',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'User not found',
          statusCode: 404,
        );
      }
      
      if (e.response?.statusCode == 422) {
        return ApiResponse.error(
          message: 'Validation error',
          errors: e.response?.data['errors'] as Map<String, dynamic>?,
          statusCode: 422,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to update user',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Delete user
  /// DELETE /{panel}/users/{id}
  Future<ApiResponse<void>> deleteUser(int id) async {
    try {
      final response = await _apiClient.dio.delete('/$panel/users/$id');

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: null,
          message: 'User deleted successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to delete user',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'User not found',
          statusCode: 404,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to delete user',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}
