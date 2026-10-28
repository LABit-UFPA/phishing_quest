import 'package:dio/dio.dart';

abstract interface class IPqApiClient {
  Future<Response> get(
    String url, {
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParams,
  });

  Future<Response> post(
    String url,
    dynamic body, {
    Map<String, dynamic> headers = const {},
    Duration? receiveTimeout,
  });

  Future<Response> put(
    String url,
    dynamic body, {
    Map<String, dynamic> headers = const {},
  });
}
