import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/template_model.dart';
import '../../services/api_service.dart';
import '../../services/effect_pipeline.dart';

/// Drives the editor screen: photo picking, intensity slider,
/// on-device effects and backend AI styling.
class EditorController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final EffectPipeline _pipeline = EffectPipeline();
  final ImagePicker _picker = ImagePicker();

  late final TrendTemplate template;

  final photoPath = Rx<String?>(null);
  final intensity = 0.6.obs; // Style Intensity slider, 0..1
  final isProcessing = false.obs;
  final aiImageBytes = Rx<Uint8List?>(null);
  final error = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    template = Get.arguments as TrendTemplate;
  }

  Future<void> pickPhoto() async {
    error.value = null;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) {
      photoPath.value = picked.path;
      aiImageBytes.value = null; // new photo invalidates any AI result
    }
  }

  /// Calls the backend AI style endpoint (never the AI API directly).
  Future<void> enhance() async {
    if (photoPath.value == null) {
      error.value = 'Pick a photo first.';
      return;
    }
    isProcessing.value = true;
    error.value = null;
    try {
      final prompt = template.aiPrompt ?? '${template.title} style';
      final bytes =
          await _api.requestAiStyle(prompt: prompt, width: 1024, height: 1792);
      aiImageBytes.value = bytes;
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/ai_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      photoPath.value = file.path;
    } catch (e) {
      error.value = 'AI enhance failed: $e';
    } finally {
      isProcessing.value = false;
    }
  }

  /// Applies the on-device filter with the current intensity, then returns
  /// the output path for the export screen.
  Future<String?> buildFinalOutput() async {
    final input = photoPath.value;
    if (input == null) return null;
    isProcessing.value = true;
    error.value = null;
    try {
      final out = await _pipeline.applyFilter(
        input,
        brightness: 0.04 + 0.12 * intensity.value,
        saturation: 1.0 + 0.5 * intensity.value,
      );
      return out;
    } catch (e) {
      error.value = 'Effect failed: $e';
      return null;
    } finally {
      isProcessing.value = false;
    }
  }
}
