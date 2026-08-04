import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Contract the [ApiClient] needs to attach auth headers and recover from a
/// 401. Implemented by the provider that owns the session (UserProvider).
///
/// Kept intentionally small so it can be registered on the client via a
/// mutable field after construction — this breaks the otherwise-circular
/// dependency between the token owner and the client it uses.
abstract class AuthTokenProvider {
  /// Current bearer access token, or null/empty when signed out.
  String? get accessToken;

  /// Attempt to refresh the access token. Returns true on success.
  /// The implementation MUST NOT route this call back through an authed,
  /// auto-retrying request (it would loop) — use [ApiClient] with `auth: false`
  /// or a raw request.
  Future<bool> refreshAccessToken();

  /// Called when a 401 could not be recovered (refresh failed/absent).
  Future<void> onAuthFailure();
}

/// Result of an API call: the HTTP status and the decoded JSON body (or null
/// when the body is empty or not valid JSON). Callers keep their own envelope
/// checks via [data]; the helpers cover the common `{ success, message }` shape.
class ApiResponse {
  final int statusCode;
  final dynamic data;

  const ApiResponse(this.statusCode, this.data);

  bool get ok => statusCode >= 200 && statusCode < 300;

  bool get isSuccess => ok && data is Map && data['success'] == true;

  String? get message => data is Map ? data['message']?.toString() : null;
}

/// Thin wrapper over `http` centralizing base URL, JSON headers, timeouts,
/// safe decoding, and a generic 401 -> refresh -> retry-once flow.
class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final String baseUrl;

  /// Registered after construction (e.g. `apiClient.authProvider = this` inside
  /// UserProvider's constructor) to avoid a constructor-time dependency cycle.
  AuthTokenProvider? authProvider;

  static const Duration _defaultTimeout = Duration(seconds: 12);

  Future<ApiResponse> get(
    String path, {
    bool auth = false,
    Duration? timeout,
  }) =>
      _send('GET', path, auth: auth, timeout: timeout);

  Future<ApiResponse> post(
    String path, {
    Object? body,
    bool auth = false,
    Duration? timeout,
  }) =>
      _send('POST', path, body: body, auth: auth, timeout: timeout);

  Future<ApiResponse> put(
    String path, {
    Object? body,
    bool auth = false,
    Duration? timeout,
  }) =>
      _send('PUT', path, body: body, auth: auth, timeout: timeout);

  Future<ApiResponse> patch(
    String path, {
    Object? body,
    bool auth = false,
    Duration? timeout,
  }) =>
      _send('PATCH', path, body: body, auth: auth, timeout: timeout);

  Future<ApiResponse> delete(
    String path, {
    Object? body,
    bool auth = false,
    Duration? timeout,
  }) =>
      _send('DELETE', path, body: body, auth: auth, timeout: timeout);

  Future<ApiResponse> _send(
    String method,
    String path, {
    Object? body,
    bool auth = false,
    Duration? timeout,
    bool retried = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (auth) {
      final token = authProvider?.accessToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final encodedBody = body == null ? null : jsonEncode(body);
    final effectiveTimeout = timeout ?? _defaultTimeout;

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers).timeout(effectiveTimeout);
        break;
      case 'POST':
        response = await http
            .post(uri, headers: headers, body: encodedBody)
            .timeout(effectiveTimeout);
        break;
      case 'PUT':
        response = await http
            .put(uri, headers: headers, body: encodedBody)
            .timeout(effectiveTimeout);
        break;
      case 'PATCH':
        response = await http
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(effectiveTimeout);
        break;
      case 'DELETE':
        response = await http
            .delete(uri, headers: headers, body: encodedBody)
            .timeout(effectiveTimeout);
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    // Generic 401 recovery: refresh once, then retry the original request.
    if (response.statusCode == 401 && auth && !retried && authProvider != null) {
      final refreshed = await authProvider!.refreshAccessToken();
      if (refreshed) {
        return _send(
          method,
          path,
          body: body,
          auth: auth,
          timeout: timeout,
          retried: true,
        );
      }
      await authProvider!.onAuthFailure();
    }

    return ApiResponse(response.statusCode, _decode(response.body));
  }

  /// Multipart upload (e.g. avatar / property images). Streams [bytes] under
  /// the given form [field] and applies the same auth + 401-retry semantics.
  Future<ApiResponse> uploadFile(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    bool auth = true,
    Duration? timeout,
    bool retried = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    if (auth) {
      final token = authProvider?.accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.files.add(
      http.MultipartFile.fromBytes(field, bytes, filename: filename),
    );

    final streamed =
        await request.send().timeout(timeout ?? const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 && auth && !retried && authProvider != null) {
      final refreshed = await authProvider!.refreshAccessToken();
      if (refreshed) {
        return uploadFile(
          path,
          field: field,
          bytes: bytes,
          filename: filename,
          auth: auth,
          timeout: timeout,
          retried: true,
        );
      }
      await authProvider!.onAuthFailure();
    }

    return ApiResponse(response.statusCode, _decode(response.body));
  }

  dynamic _decode(String rawBody) {
    if (rawBody.isEmpty) return null;
    try {
      return jsonDecode(rawBody);
    } catch (_) {
      return null;
    }
  }
}
