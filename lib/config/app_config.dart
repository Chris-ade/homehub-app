/// Centralized, compile-time-overridable app configuration.
///
/// Override any value at build/run time with `--dart-define`, e.g.:
///   flutter run --dart-define=API_BASE_URL=http://localhost:8080/api
///
/// This is the single source of truth for backend URLs — do not hardcode the
/// host anywhere else in the app.
class AppConfig {
  const AppConfig._();

  /// Base URL for the REST API, including the trailing `/api` segment.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://rentalhub-api-0kuk.onrender.com/api',
  );

  /// WebSocket endpoint for realtime chat (reserved for the chat integration).
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://rentalhub-api-0kuk.onrender.com/api/messages/ws',
  );

  /// Bare origin (scheme + host, no `/api`) used to resolve server-relative
  /// asset/image URLs returned by the backend.
  static String get apiHost {
    const suffix = '/api';
    if (apiBaseUrl.endsWith(suffix)) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - suffix.length);
    }
    return Uri.parse(apiBaseUrl).origin;
  }
}
