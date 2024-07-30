import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// A widget that displays a camera preview with optional custom painting.
///
/// This widget wraps the [CameraPreview] widget and adds the ability to show
/// custom paint on top of the camera feed. It also handles a state where the
/// camera lens is being changed.
class CameraPreviewWidget extends StatelessWidget {
  /// The controller for the camera being displayed.
  final CameraController controller;

  /// Optional custom paint to be drawn on top of the camera preview.
  final CustomPaint? customPaint;

  /// Indicates whether the camera lens is currently being changed.
  ///
  /// If true, a message will be displayed instead of the camera preview.
  final bool changingCameraLens;

  /// Creates a [CameraPreviewWidget].
  ///
  /// The [controller] parameter is required and must not be null.
  /// The [customPaint] parameter is optional and allows for custom drawing on top of the camera preview.
  /// The [changingCameraLens] parameter defaults to false and indicates if the camera lens is being switched.
  const CameraPreviewWidget({
    super.key,
    required this.controller,
    this.customPaint,
    this.changingCameraLens = false,
  });

  @override
  Widget build(BuildContext context) {
    if (changingCameraLens) {
      // Display a message when the camera lens is being changed
      return const Center(child: Text('Changing camera lens'));
    }
    // Display the camera preview with optional custom paint
    return CameraPreview(
      controller,
      child: customPaint,
    );
  }
}