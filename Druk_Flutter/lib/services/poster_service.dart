import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'dart:io';

class PosterService {
  /// Captures a widget wrapped in a RepaintBoundary
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Use a high pixel ratio for "Print Quality" posters (Retina-like)
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Poster capture failed: $e');
      return null;
    }
  }

  /// Saves image to the phone's gallery using Gal
  static Future<bool> saveToGallery(Uint8List bytes, String fileName) async {
    try {
      // Gal is more modern and handles AGP 8.0+ namespaces correctly
      await Gal.putImageBytes(bytes, name: fileName);
      return true;
    } catch (e) {
      debugPrint('Save to gallery failed: $e');
      return false;
    }
  }

  /// Shares the image using the system share sheet
  static Future<void> shareImage(Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName.png').create();
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Sharing my Druk Moment 🥂',
    );
  }
}
