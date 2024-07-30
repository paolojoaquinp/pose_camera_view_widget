import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pose_camera_view/src/enums/enums.dart';

export 'camera_controller.dart';
export 'pose_detector.dart';

/// A utility class containing various helper methods.
class Utils {
  /// Retrieves the local file path for a given asset and ensures the file exists.
  ///
  /// If the file doesn't exist, it creates the file from the asset bundle.
  ///
  /// [asset] The asset path to retrieve.
  ///
  /// Returns a [Future] that completes with the local file path of the asset.
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

  /// Extracts the directory path from a full file path.
  ///
  /// [path] The full file path.
  ///
  /// Returns the directory path as a [String].
  static String _dirname(String path) {
    return path.substring(0, path.lastIndexOf('/'));
  }

  /// Generates a local path for a given asset.
  ///
  /// This method creates a temporary directory and returns a path within it.
  ///
  /// [asset] The asset for which to generate a local path.
  ///
  /// Returns a [Future] that completes with the generated local path as a [String].
  static Future<String> getLocalPath(String asset) async {
    final directory = await Directory.systemTemp.createTemp();
    return '${directory.path}/$asset';
  }

  /// Calculates the angle between three landmarks.
  ///
  /// [firstLandmark] The first landmark point.
  /// [midLandmark] The middle landmark point (vertex of the angle).
  /// [lastLandmark] The last landmark point.
  ///
  /// Returns the angle in degrees as a [double].
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

  /// Determines the state of a push-up based on the elbow angle and current state.
  ///
  /// [angleElbow] The current angle of the elbow.
  /// [current] The current state of the push-up.
  /// [umbralElbowFlexion] The threshold angle for elbow flexion.
  /// [umbralElbowExtension] The threshold angle for elbow extension.
  ///
  /// Returns the new [PushUpState] if a state change is detected, or null if no change.
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