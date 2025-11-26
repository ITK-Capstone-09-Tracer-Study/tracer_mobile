import 'package:dio/dio.dart';
import '../models/major_model.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Service untuk handle Major API
/// Endpoint: /{panel}/majors
class MajorService {
  final ApiClient _apiClient = ApiClient();
  
  /// Panel untuk admin operations
  static const String panel = 'admin';

  /// Get paginated list of majors
  /// GET /{panel}/majors?page=1&per_page=10
  Future<ApiResponse<PaginatedResponse<MajorModel>>> getMajors({
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
        '/$panel/majors',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final paginatedData = PaginatedResponse<MajorModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MajorModel.fromJson(json),
        );
        
        return ApiResponse.success(
          data: paginatedData,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch majors',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch majors',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get all majors without pagination (for dropdowns)
  /// GET /{panel}/majors?per_page=-1 or high number
  Future<ApiResponse<List<MajorModel>>> getAllMajors({
    String? include,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': 1000, // Get all majors
      };
      
      if (include != null) queryParams['include'] = include;

      final response = await _apiClient.dio.get(
        '/$panel/majors',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dataList = response.data['data'] as List<dynamic>;
        final majors = dataList
            .map((json) => MajorModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse.success(
          data: majors,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch majors',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch majors',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get single major by ID
  /// GET /{panel}/majors/{id}
  Future<ApiResponse<MajorModel>> getMajor(int id) async {
    try {
      final response = await _apiClient.dio.get('/$panel/majors/$id');

      if (response.statusCode == 200) {
        final majorData = response.data['data'] as Map<String, dynamic>;
        final major = MajorModel.fromJson(majorData);
        
        return ApiResponse.success(
          data: major,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch major',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'Major not found',
          statusCode: 404,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to fetch major',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Create new major
  /// POST /{panel}/majors
  Future<ApiResponse<MajorModel>> createMajor(MajorModel major) async {
    try {
      final response = await _apiClient.dio.post(
        '/$panel/majors',
        data: major.toRequestJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final majorData = response.data['data'] as Map<String, dynamic>;
        final createdMajor = MajorModel.fromJson(majorData);
        
        return ApiResponse.success(
          data: createdMajor,
          message: 'Major created successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to create major',
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
        message: e.response?.data['message'] ?? 'Failed to create major',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update major
  /// PUT /{panel}/majors/{id}
  Future<ApiResponse<MajorModel>> updateMajor(int id, MajorModel major) async {
    try {
      final response = await _apiClient.dio.put(
        '/$panel/majors/$id',
        data: major.toRequestJson(),
      );

      if (response.statusCode == 200) {
        final majorData = response.data['data'] as Map<String, dynamic>;
        final updatedMajor = MajorModel.fromJson(majorData);
        
        return ApiResponse.success(
          data: updatedMajor,
          message: 'Major updated successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to update major',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'Major not found',
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
        message: e.response?.data['message'] ?? 'Failed to update major',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Delete major
  /// DELETE /{panel}/majors/{id}
  Future<ApiResponse<MajorModel?>> deleteMajor(int id) async {
    try {
      final response = await _apiClient.dio.delete('/$panel/majors/$id');

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: null,
          message: 'Major deleted successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Failed to delete major',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(
          message: 'Major not found',
          statusCode: 404,
        );
      }
      
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Failed to delete major',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}
