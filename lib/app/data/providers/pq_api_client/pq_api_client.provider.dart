import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:phishing_quest/app/data/providers/pq_api_client/pq_api_client.interface.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/data/util/api/api_exception_handler.dart';
import 'package:phishing_quest/app/data/util/api/api_helpers.dart';

typedef Header = Map<String, dynamic>;
typedef Request = Future<Response> Function();

/// `PqApiClient` serves as a HTTP client.
/// It has methods for processing GET, POST, PUT HTTP requests.
/// It utilizes the Dio HTTP client under the hood for sending these requests.
/// Errors encountered during requests are caught and logging is done using the Debugger class.
/// API related helpers are accessed from the ApiHelpers class.
///
/// O certificado TLS do servidor e validado normalmente: o cliente nao
/// aceita certificado invalido em nenhum ambiente.
class PqApiClient extends GetxService implements IPqApiClient {
  late final Dio _dio;
  late final ApiHelpers _apiHelpers;

  /// Constructs a `PqApiClient` instance.
  ///
  /// - `apiHelpers` - Instance of ApiHelpers.
  /// - `dio` - Dio HTTP client instance.
  PqApiClient({
    ApiHelpers? apiHelpers,
    Dio? dio,
  }) {
    _apiHelpers = apiHelpers ?? ApiHelpers();
    _dio = dio ?? Dio()
      ..interceptors.add(_apiHelpers.getInterceptor());
  }

  /// Sends a GET request to the given `url` with optional `headers`.
  ///
  /// On exception, returns an error Response.
  @override
  Future<Response> get(String url, {Header headers = const {}, Map<String, dynamic>? queryParams}) {
    final options = _apiHelpers.generateOptions()..headers?.addAll(headers);

    return _sendRequest(options, () => _dio.get(url, options: options, queryParameters: queryParams));
  }

  /// Sends a POST request to the given `url` with `body` and optional `headers`.
  /// `receiveTimeout` alonga a espera de chamadas lentas, como a geracao
  /// de itens pelo PhishForge.
  ///
  /// On exception, returns an error Response.
  @override
  Future<Response> post(String url, dynamic body, {Header headers = const {}, Duration? receiveTimeout}) {
    final options = _apiHelpers.generateOptions()..headers?.addAll(headers);
    if (receiveTimeout != null) {
      options.receiveTimeout = receiveTimeout;
    }

    return _sendRequest(options, () => _dio.post(url, data: body, options: options));
  }

  /// Sends a PUT request to the given `url` with `body` and optional `headers`.
  ///
  /// On exception, returns an error Response.
  @override
  Future<Response> put(String url, dynamic body, {Header headers = const {}}) {
    final options = _apiHelpers.generateOptions()..headers?.addAll(headers);

    return _sendRequest(options, () => _dio.put(url, data: body, options: options));
  }

  /// Private method that sends an HTTP request and handles exceptions.
  ///
  /// On exception, returns an error Response that keeps the server body
  /// (the API answers `{"error": "..."}`). Without a server response
  /// (no network, timeout), `statusCode` is null and `data` carries the
  /// user-facing message. A 401 on an authenticated request ends the
  /// session: the token expired or was revoked.
  Future<Response> _sendRequest(Options options, Request request) async {
    try {
      return await request();
    } catch (err) {
      if (err is! DioException) {
        rethrow;
      }

      final statusCode = err.response?.statusCode;
      final hadToken = options.headers?.containsKey('Authorization') ?? false;
      if (statusCode == 401 && hadToken && Get.isRegistered<AuthService>()) {
        Get.find<AuthService>().onSessionExpired();
      }

      return Response(
        requestOptions: err.requestOptions,
        statusCode: statusCode,
        data: err.response?.data ?? ApiExceptionHandler.fromDioError(err).message,
      );
    }
  }
}
