import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/routes.dart';
import '../../theme/app_colors.dart';
import '../controllers/premium_controller.dart';
import '../models/template_model.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pro_badge.dart';
import '../../services/creation_storage.dart';

/// Export: Free (watermark) vs Pro (no watermark) plan selector,
/// share row and save-to-device.
class ExportView extends StatefulWidget {
  const ExportView({super.key});

  @override
  State<ExportView> createState() => _ExportViewState();
}

class _ExportViewState extends State<ExportView> {
  bool _proPlan = false;
  bool _busy = false;

  late final String _path;
  late final TrendTemplate _template;
  final _storage = CreationStorage();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _path = args['path'] as String;
    _template = args['template'] as TrendTemplate;
    _proPlan = Get.find<PremiumController>().isPremium.value;
  }

  Future<void> _share(String label) async {
    setState(() => _busy = true);
    try {
      await Share.shareXFiles(
        [XFile(_path)],
        text: 'Made with TrendLens · ${_template.title} $label',
      );
    } catch (e) {
      if (mounted) Get.snackbar('Share failed', '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveToDevice() async {
    setState(() => _busy = true);
    try {
      final bytes = await File(_path).readAsBytes();
      final name =
          'trendlens_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _storage.saveLocal(bytes, name);
      if (mounted) {
        Get.snackbar('Saved', 'Your creation is in My Creations.');
      }
    } catch (e) {
      if (mounted) Get.snackbar('Save failed', '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = Get.find<PremiumController>().isPremium.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(File(_path),
                    height: 300, width: double.infinity, fit: BoxFit.cover),
              ),
              if (!_proPlan) ...[
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Exported with TrendLens watermark',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Export plan',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _planCard(
                context,
                title: 'Free',
                subtitle: 'With watermark',
                selected: !_proPlan,
                onTap: () => setState(() => _proPlan = false),
              ),
              const SizedBox(height: 10),
              _planCard(
                context,
                title: 'Pro',
                subtitle: 'No watermark · cloud backup',
                badge: const ProBadge(),
                selected: _proPlan,
                locked: !isPremium,
                onTap: () {
                  if (isPremium) {
                    setState(() => _proPlan = true);
                  } else {
                    Get.toNamed(Routes.paywall);
                  }
                },
              ),
              if (!isPremium) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cloud backup is a Pro feature. '
                          'Free creations stay on this device.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.paywall),
                        child: const Text('Go Pro'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Share to',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _shareButton(context, Icons.music_note, 'TikTok',
                      () => _share('#TikTok')),
                  _shareButton(context, Icons.camera_alt_outlined, 'Reels',
                      () => _share('#Reels')),
                  _shareButton(context, Icons.play_arrow, 'Shorts',
                      () => _share('#Shorts')),
                  _shareButton(context, Icons.download_outlined,
                      'Save', _saveToDevice),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: _busy ? 'Working…' : 'Done',
                onPressed: _busy ? null : () => Get.offAllNamed(Routes.main),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool selected,
    Widget? badge,
    bool locked = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : theme.dividerColor.withOpacity(0.4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        badge,
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locked ? '$subtitle · tap to unlock' : subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Icon(
              locked
                  ? Icons.lock_outline
                  : (selected
                      ? Icons.check_circle
                      : Icons.circle_outlined),
              color: locked ? theme.hintColor : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _busy ? null : onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
