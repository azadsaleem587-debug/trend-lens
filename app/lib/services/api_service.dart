import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../app/models/template_model.dart';

/// HTTP client for the TrendLens backend.
///
/// NEVER call Pollinations (or any third-party AI API) directly from the app:
///  - API keys would ship inside the APK/IPA where anyone can extract them.
///  - The backend centralises caching, rate limiting and watermarking,
///    keeping the $0 stack cheap and abuse-proof.
/// All AI work goes through the backend's /api/ai/style proxy endpoint.
class ApiService {
  final http.Client _client = http.Client();

  /// GET /api/templates — throws on non-200 so callers can fall back
  /// to the bundled assets/templates.json.
  Future<List<TrendTemplate>> fetchTemplates() async {
    final res = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.templatesEndpoint}'),
    );
    if (res.statusCode != 200) {
      throw Exception('GET /api/templates failed: ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    final list = data is Map ? data['templates'] : data;
    return (list as List)
        .map((e) => TrendTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/ai/style {prompt, width, height} -> raw image bytes.
  /// The backend proxies Pollinations with a server-side disk cache.
  Future<Uint8List> requestAiStyle({
    required String prompt,
    int width = 1024,
    int height = 1792,
  }) async {
    final res = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.aiStyleEndpoint}'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt, 'width': width, 'height': height}),
    );
    if (res.statusCode != 200) {
      throw Exception('POST /api/ai/style failed: ${res.statusCode}');
    }
    return res.bodyBytes;
  }
}
