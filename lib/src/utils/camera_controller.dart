import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

/// Utility class for camera controller operations and image processing.
class CameraControllerUtils {
  /// Initializes and returns a [CameraController] for the given [camera].
  ///
  /// Sets up the camera with high resolution and platform-specific image format.
  /// Audio is disabled for this controller.
  ///
  /// [camera] The description of the camera to be used.
  ///
  /// Returns a [Future] that completes with the initialized [CameraController].
  static Future<CameraController> initializeCameraController(
      CameraDescription camera,
      ) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await controller.initialize();
    return controller;
  }

  /// Converts a [CameraImage] to an [InputImage] for use with ML Kit.
  ///
  /// Handles platform-specific image rotation and format conversion.
  ///
  /// [image] The camera image to convert.
  /// [controller] The current camera controller.
  /// [camera] The description of the current camera.
  ///
  /// Returns an [InputImage] if conversion is successful, null otherwise.
  static InputImage? inputImageFromCameraImage(
      CameraImage image,
      CameraController controller,
      CameraDescription camera,
      ) {
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw as int);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  /// Map of device orientations to their corresponding rotation values in degrees.
  static final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
}