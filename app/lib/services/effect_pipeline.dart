import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

/// On-device effect pipeline built on ffmpeg_kit_flutter.
/// Only fully-implemented effects are callable without throwing;
/// stubs throw [UnimplementedError] with explicit TODO markers.
class EffectPipeline {
  /// (a) Brightness/saturation filter via ffmpeg `eq`.
  Future<String> applyFilter(
    String inputPath, {
    double brightness = 0.08,
    double saturation = 1.25,
  }) async {
    final out = await _tempOutput('filtered');
    final session = await FFmpegKit.execute(
      "-y -i '$inputPath' "
      "-vf eq=brightness=$brightness:saturation=$saturation "
      "'$out'",
    );
    await _throwIfFailed(session, 'applyFilter');
    return out;
  }

  /// (b) Caption overlay via ffmpeg `drawtext` (bottom-centre, outlined).
  Future<String> addCaption(String inputPath, String text) async {
    final out = await _tempOutput('captioned');
    final safe = text.replaceAll("'", '’').replaceAll(':', r'\:');
    final session = await FFmpegKit.execute(
      "-y -i '$inputPath' "
      "-vf \"drawtext=text='$safe':fontcolor=white:fontsize=64:"
      "borderw=3:bordercolor=black:x=(w-text_w)/2:y=h-200\" "
      "'$out'",
    );
    await _throwIfFailed(session, 'addCaption');
    return out;
  }

  /// TODO: implement once transition assets are finalized —
  /// wire ffmpeg `xfade`/`zoompan` between the photo clip and the effect clip.
  Future<String> applyTransition(String inputPath, String transition) {
    throw UnimplementedError(
      'applyTransition is a stub: TODO — implement ffmpeg xfade/zoompan '
      'after transition assets are finalized.',
    );
  }

  /// TODO: implement once the backend beat-map API exists —
  /// needs per-track beat times before ffmpeg `select`/`atempo` cuts are possible.
  Future<String> beatSyncCut(String inputPath, List<double> beatTimes) {
    throw UnimplementedError(
      'beatSyncCut is a stub: TODO — needs the backend beat-map API; '
      'do not call until beat times are available.',
    );
  }

  Future<String> _tempOutput(String prefix) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  Future<void> _throwIfFailed(FFmpegSession session, String op) async {
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('$op failed (rc=${code?.getValue()}): $logs');
    }
  }
}
