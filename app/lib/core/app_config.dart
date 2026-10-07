/// Central configuration for the TrendLens app.
class AppConfig {
  /// Base URL of the TrendLens backend (Node.js + Express server on the Servarica VPS).
  ///
  /// Default points at the Android emulator loopback (10.0.2.2).
  /// CHANGE THIS to your Servarica server URL/IP when testing on physical devices.
  static const String apiBaseUrl = 'http://10.0.2.2:3000';

  static const String templatesEndpoint = '/api/templates';
  static const String aiStyleEndpoint = '/api/ai/style';
  static const String uploadEndpoint = '/api/upload';
}
