import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../app/controllers/premium_controller.dart';
import '../core/app_config.dart';

/// Storage rules (core business logic):
///  - FREE users: creations live in the app documents directory only.
///  - PREMIUM users (PremiumController.isPremium): may also upload to
///    POST /api/upload with `x-premium: true` + `x-user-id` headers.
///
/// NOTE: this gate is enforced client-side for UX; the server enforces it
/// too — uploads without a valid premium header are rejected server-side.
class CreationStorage {
  final PremiumController _premium = Get.find<PremiumController>();
  final http.Client _client = http.Client();

  Future<Directory> _creationsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/creations');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Save a finished creation locally (free tier home).
  Future<File> saveLocal(Uint8List bytes, String fileName) async {
    final dir = await _creationsDir();
    final file = File('${dir.path}/$fileName');
    return file.writeAsBytes(bytes);
  }

  /// All locally saved creations, newest first.
  Future<List<File>> listLocal() async {
    final dir = await _creationsDir();
    final files = await dir
        .list()
        .where((e) => e is File)
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  /// Cloud backup — premium only. The server double-checks the headers.
  Future<void> uploadCloud(File file, String userId) async {
    if (!_premium.isPremium.value) {
      throw StateError(
        'Cloud backup is a Pro feature. Upgrade to save creations to the cloud.',
      );
    }
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.uploadEndpoint}'),
    );
    req.headers['x-premium'] = 'true';
    req.headers['x-user-id'] = userId;
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await _client.send(req);
    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      throw Exception('Cloud upload failed: ${streamed.statusCode}');
    }
  }
}
