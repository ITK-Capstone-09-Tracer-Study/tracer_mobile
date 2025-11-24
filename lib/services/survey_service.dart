import 'package:dio/dio.dart';
import '../models/survey_model.dart';
import '../models/survey_kind_model.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Service untuk handle Survey API
/// Endpoint: /{panel}/surveys dan /{panel}/survey-kinds
class SurveyService {
  final ApiClient _apiClient = ApiClient();
  
  /// Panel untuk tracer team operations
  static const String panel = 'tracer_team';

  /// Get list of Survey Kinds (Templates)
  /// GET /{panel}/survey-kinds
  Future<ApiResponse<List<SurveyKindModel>>> getSurveyKinds() async {
    try {
      final response = await _apiClient.dio.get('/$panel/survey-kinds');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final surveyKinds = data.map((json) => SurveyKindModel.fromJson(json)).toList();
        
        return ApiResponse.success(
          data: surveyKinds,
          message: 'Survey kinds fetched successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch survey kinds',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch survey kinds',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Get list of Surveys
  /// GET /{panel}/surveys
  Future<ApiResponse<List<SurveyModel>>> getSurveys({
    int page = 1,
    int perPage = 100, // Fetch many for now to group by year
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/$panel/surveys',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'include': 'kind', // Include SurveyKind relation
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final surveys = data.map((json) => SurveyModel.fromJson(json)).toList();
        
        return ApiResponse.success(
          data: surveys,
          message: 'Surveys fetched successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to fetch surveys',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch surveys',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Create Survey
  /// POST /{panel}/surveys
  Future<ApiResponse<SurveyModel>> createSurvey(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/$panel/surveys',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data['data'] ?? response.data;
        return ApiResponse.success(
          data: SurveyModel.fromJson(responseData),
          message: 'Survey created successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to create survey',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to create survey',
        statusCode: e.response?.statusCode,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Update Survey
  /// PUT /{panel}/surveys/{id}
  Future<ApiResponse<SurveyModel>> updateSurvey(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/$panel/surveys/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'] ?? response.data;
        return ApiResponse.success(
          data: SurveyModel.fromJson(responseData),
          message: 'Survey updated successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to update survey',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to update survey',
        statusCode: e.response?.statusCode,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Delete Survey
  /// DELETE /{panel}/surveys/{id}
  Future<ApiResponse<void>> deleteSurvey(int id) async {
    try {
      final response = await _apiClient.dio.delete('/$panel/surveys/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(
          data: null,
          message: 'Survey deleted successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to delete survey',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to delete survey',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Create Survey Kind
  /// POST /{panel}/survey-kinds
  Future<ApiResponse<SurveyKindModel>> createSurveyKind(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/$panel/survey-kinds',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'] ?? response.data;
        return ApiResponse.success(
          data: SurveyKindModel.fromJson(responseData),
          message: 'Survey kind created successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to create survey kind',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to create survey kind',
        statusCode: e.response?.statusCode,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Update Survey Kind
  /// PUT /{panel}/survey-kinds/{id}
  Future<ApiResponse<SurveyKindModel>> updateSurveyKind(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/$panel/survey-kinds/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'] ?? response.data;
        return ApiResponse.success(
          data: SurveyKindModel.fromJson(responseData),
          message: 'Survey kind updated successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to update survey kind',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to update survey kind',
        statusCode: e.response?.statusCode,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Delete Survey Kind
  /// DELETE /{panel}/survey-kinds/{id}
  Future<ApiResponse<void>> deleteSurveyKind(int id) async {
    try {
      final response = await _apiClient.dio.delete('/$panel/survey-kinds/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(
          data: null,
          message: 'Survey kind deleted successfully',
        );
      }

      return ApiResponse.error(
        message: 'Failed to delete survey kind',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to delete survey kind',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred: $e');
    }
  }
}
