import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final CustomPaint? customPaint;
  final bool changingCameraLens;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    this.customPaint,
    this.changingCameraLens = false,
  });

  @override
  Widget build(BuildContext context) {
    if (changingCameraLens) {
      return const Center(child: Text('Changing camera lens'));
    }
    return CameraPreview(
      controller,
      child: customPaint,
    );
  }
}