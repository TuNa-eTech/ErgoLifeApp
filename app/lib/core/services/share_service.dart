import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Service for rendering widgets to images and sharing.
///
/// Uses [RenderRepaintBoundary] to capture a widget tree
/// as a PNG image, then shares it via the OS share sheet.
class ShareService {
  /// Captures the widget bound to [boundaryKey] as a PNG
  /// and opens the native share sheet.
  ///
  /// [pixelRatio] controls image resolution (3.0 = 3x).
  /// [subject] is the share sheet subject line.
  Future<void> shareFromBoundary(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
    String subject = 'My ErgoLife Achievement',
    String text = 'Check out my workout on ErgoLife! 💪🔥',
  }) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        AppLogger.warning('RepaintBoundary not found', 'ShareService');
        return;
      }

      // Wait for paint to complete if needed
      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      await _shareImage(pngBytes, subject: subject, text: text);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to share: $e', e, stackTrace, 'ShareService');
    }
  }

  /// Shares a PNG image via the OS share sheet.
  Future<void> _shareImage(
    Uint8List pngBytes, {
    required String subject,
    required String text,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/ergolife_achievement.png');
    await file.writeAsBytes(pngBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: subject,
        text: text,
      ),
    );
  }
}
