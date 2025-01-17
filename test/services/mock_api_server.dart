import 'dart:convert';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

class MockApiServer extends Mock {
  static const baseUrl = 'http://localhost:8080';

  static Response<Map<String, dynamic>> successResponse({
    Map<String, dynamic>? data,
    int statusCode = 200,
  }) {
    return Response(
      data: {
        'success': true,
        'code': null,
        'message': null,
        'data': data ?? {'result': 'success'},
      },
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    );
  }

  static Response<Map<String, dynamic>> errorResponse({
    required int code,
    String? message,
    Map<String, dynamic>? data,
    int statusCode = 400,
  }) {
    return Response(
      data: {
        'success': false,
        'code': code,
        'message': message ?? 'Error occurred',
        'data': data,
      },
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    );
  }

  static Response<Map<String, dynamic>> invalidResponse() {
    return Response(
      data: {'invalid': 'format'},
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );
  }

  static DioException timeoutException() {
    return DioException(
      type: DioExceptionType.connectionTimeout,
      requestOptions: RequestOptions(path: ''),
      message: 'Connection timeout',
    );
  }

  static DioException networkException() {
    return DioException(
      type: DioExceptionType.connectionError,
      requestOptions: RequestOptions(path: ''),
      message: 'Network error',
    );
  }

  static Map<String, String> get defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-API-Key': 'test-api-key',
  };

  static String encodeJson(Map<String, dynamic> data) {
    return json.encode(data);
  }
} 