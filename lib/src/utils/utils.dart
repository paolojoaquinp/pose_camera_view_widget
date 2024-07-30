import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pose_camera_view/src/enums/enums.dart';


export 'camera_controller.dart';
export 'pose_detector.dart';

class Utils {
  static Future<String> getAssetPath(String asset) async {
    final localPath = await getLocalPath(asset);

    await Directory(_dirname(localPath)).create(recursive: true);

    final file = File(localPath);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  static String _dirname(String path) {
    return path.substring(0, path.lastIndexOf('/'));
  }

  static Future<String> getLocalPath(String asset) async {
    // Implementa la lógica para obtener la ruta local del asset
    // Por ejemplo, podrías usar el directorio temporal o de documentos
    final directory = await Directory.systemTemp.createTemp();
    return '${directory.path}/$asset';
  }

  static double angle(PoseLandmark firstLandmark, PoseLandmark midLandmark,
      PoseLandmark lastLandmark) {
    final radians = math.atan2(
            lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) -
        math.atan2(
            firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);
    double degrees = radians * 180.0 / math.pi;
    degrees = degrees.abs();
    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }
    return degrees;
  }

  static PushUpState? isPushUp(double angleElbow, PushUpState current,
      double umbralElbowFlexion, double umbralElbowExtension) {
    if (current == PushUpState.init &&
        angleElbow > umbralElbowExtension &&
        angleElbow < 180.0) {
      return PushUpState.middle;
    } else if (current == PushUpState.middle &&
        angleElbow < umbralElbowFlexion &&
        angleElbow > 30.0) {
      return PushUpState.completed;
    }
    return null;
  }
}
