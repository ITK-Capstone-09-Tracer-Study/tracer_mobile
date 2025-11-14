/// API Response wrapper untuk handle response dari backend
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.statusCode,
  });

  /// Success response
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Error response
  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  /// From DioException
  factory ApiResponse.fromError(dynamic error) {
    if (error is Map<String, dynamic>) {
      return ApiResponse.error(
        message: error['message'] as String? ?? 'An error occurred',
        errors: error['errors'] as Map<String, dynamic>?,
        statusCode: error['statusCode'] as int?,
      );
    }
    return ApiResponse.error(
      message: error.toString(),
    );
  }
}

/// Paginated response untuk list data
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = (json['data'] as List)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      data: dataList,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      from: json['from'] as int? ?? 0,
      to: json['to'] as int? ?? 0,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage == lastPage;
}
