import 'package:dio/dio.dart';
import '../models/faculty_model.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Service untuk handle Faculty API
/// Endpoint: /{panel}/faculties
class FacultyService {
  final ApiClient _apiClient = ApiClient();
  
  /// Panel untuk admin operations
  static const String panel = 'admin';

  /// Get paginated list of faculties
  /// GET /{panel}/faculties?page=1&per_page=10
  Future<ApiResponse<PaginatedResponse<FacultyModel>>> getFaculties({
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
        '/$panel/faculties',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final paginatedData = PaginatedResponse<FacultyModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => FacultyModel.fromJson(json),
        );
        
        return ApiResponse.success(
          data: paginatedData,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch faculties',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch faculties',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get single faculty by ID
  /// GET /{panel}/faculties/{id}
  Future<ApiResponse<FacultyModel>> getFaculty(int id) async {
    try {
      final response = await _apiClient.dio.get('/$panel/faculties/$id');

      if (response.statusCode == 200) {
        final facultyData = response.data['data'] as Map<String, dynamic>;
        final faculty = FacultyModel.fromJson(facultyData);
        
        return ApiResponse.success(
          data: faculty,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch faculty',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'Faculty not found',
          statusCode: 404,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch faculty',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Create new faculty
  /// POST /{panel}/faculties
  Future<ApiResponse<FacultyModel>> createFaculty(FacultyModel faculty) async {
    try {
      final response = await _apiClient.dio.post(
        '/$panel/faculties',
        data: faculty.toRequestJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final facultyData = response.data['data'] as Map<String, dynamic>;
        final createdFaculty = FacultyModel.fromJson(facultyData);
        
        return ApiResponse.success(
          data: createdFaculty,
          message: 'Faculty created successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to create faculty',
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
        message: e.response?.data['message'] ?? 'Failed to create faculty',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update existing faculty
  /// PUT /{panel}/faculties/{id}
  Future<ApiResponse<FacultyModel>> updateFaculty({
    required int id,
    required FacultyModel faculty,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/$panel/faculties/$id',
        data: faculty.toRequestJson(),
      );

      if (response.statusCode == 200) {
        final facultyData = response.data['data'] as Map<String, dynamic>;
        final updatedFaculty = FacultyModel.fromJson(facultyData);
        
        return ApiResponse.success(
          data: updatedFaculty,
          message: 'Faculty updated successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to update faculty',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'Faculty not found',
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
        message: e.response?.data['message'] ?? 'Failed to update faculty',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Delete faculty
  /// DELETE /{panel}/faculties/{id}
  Future<ApiResponse<void>> deleteFaculty(int id) async {
    try {
      final response = await _apiClient.dio.delete('/$panel/faculties/$id');

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: null,
          message: 'Faculty deleted successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to delete faculty',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'Faculty not found',
          statusCode: 404,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to delete faculty',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}
