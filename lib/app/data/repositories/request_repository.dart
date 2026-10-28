import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:phishing_quest/app/data/providers/pq_api_client/pq_api_client.provider.dart';
import 'package:phishing_quest/app/data/util/api/api_exception_handler.dart';
import 'package:phishing_quest/app/data/util/api/api_helpers.dart';

typedef ValidResponse<T> = ({bool valid, String? reason, T? data});

/// Falha de uma chamada a API. `statusCode` e nulo quando nao houve
/// resposta do servidor (sem rede, timeout).
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  bool get isNotFound => statusCode == HttpStatus.notFound;
  bool get isForbidden => statusCode == HttpStatus.forbidden;
  bool get isConflict => statusCode == HttpStatus.conflict;

  @override
  String toString() => message;
}

abstract base class RequestRepository {
  late ApiHelpers apiHelpers = ApiHelpers();
  late PqApiClient client = Get.find<PqApiClient>();

  ValidResponse<T> isValidResponse<T>(Response response) {
    final statusCode = response.statusCode ?? 400;
    if (statusCode >= 200 && statusCode < 300) {
      return (valid: true, reason: null, data: null);
    }

    return (
      valid: false,
      data: null,
      reason: errorMessage(response),
    );
  }

  /// Devolve o corpo de uma resposta 2xx ou lanca [ApiException] com a
  /// mensagem do servidor (`{"error": "..."}`) quando ela existe.
  dynamic dataOrThrow(Response response) {
    final statusCode = response.statusCode;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      return response.data;
    }
    throw ApiException(statusCode, errorMessage(response));
  }

  String errorMessage(Response response) {
    final data = response.data;
    if (response.statusCode == null) {
      return data is String && data.isNotEmpty ? data : 'Sem conexão com o servidor';
    }
    if (data is Map && data['error'] is String && response.statusCode != HttpStatus.internalServerError) {
      return data['error'] as String;
    }
    return ApiExceptionHandler.handleError(response.statusCode, data);
  }

  String url(String path) => apiHelpers.buildUrl(url: path);
}
