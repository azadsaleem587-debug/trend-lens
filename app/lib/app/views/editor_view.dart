import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes.dart';
import '../controllers/editor_controller.dart';
import '../widgets/gradient_button.dart';

/// Editor: before/after preview, Style Intensity slider,
/// Retake / Enhance / Next buttons.
class EditorView extends StatelessWidget {
  const EditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditorController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(controller.template.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _preview(context, controller)),
              const SizedBox(height: 20),
              Text(
                'Style Intensity',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Obx(() => Slider(
                    value: controller.intensity.value,
                    onChanged: (v) => controller.intensity.value = v,
                  )),
              Obx(() {
                final err = controller.error.value;
                if (err == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    err,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }),
              const Spacer(),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isProcessing.value
                              ? null
                              : controller.pickPhoto,
                          child: const Text('Retake'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isProcessing.value
                              ? null
                              : controller.enhance,
                          child: controller.isProcessing.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text('Enhance'),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 12),
              Obx(() => GradientButton(
                    label: 'Next',
                    isLoading: controller.isProcessing.value,
                    onPressed: controller.photoPath.value == null ||
                            controller.isProcessing.value
                        ? null
                        : () async {
                            final out =
                                await controller.buildFinalOutput();
                            if (out != null) {
                              Get.toNamed(
                                Routes.export,
                                arguments: {
                                  'path': out,
                                  'template': controller.template,
                                },
                              );
                            }
                          },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preview(BuildContext context, EditorController controller) {
    final path = controller.photoPath.value;
    if (path == null) {
      return GestureDetector(
        onTap: controller.pickPhoto,
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 48),
                SizedBox(height: 12),
                Text('Tap to pick a photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    // Before/after: the "after" pane previews the intensity with a
    // lightweight ColorFiltered tint; the real ffmpeg filter runs on Next.
    final intensity = controller.intensity.value;
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(path),
                    height: 280, fit: BoxFit.cover),
              ),
              const SizedBox(height: 6),
              const Text('Before',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.deepPurple.withOpacity(0.25 * intensity),
                    BlendMode.saturation,
                  ),
                  child: Image.file(File(path),
                      height: 280, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 6),
              const Text('After',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
