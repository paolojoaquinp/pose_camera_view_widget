import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

/// A custom painter that visualizes detected body poses on a canvas.

class PosePainter extends CustomPainter {
  /// Creates a [PosePainter] to paint a list of poses on a canvas.

  /// - [poses]: The list of detected poses to be visualized.
  /// - [imageSize]: The size of the original camera image.
  /// - [rotation]: The rotation of the camera image input.
  /// - [cameraLensDirection]: The direction of the camera lens.

  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  /// The list of detected poses to be visualized.
  final List<Pose> poses;

  /// The size of the original camera image.
  final Size imageSize;

  /// The rotation of the camera image input.
  final InputImageRotation rotation;

  /// The direction of the camera lens.
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    /// Paint objects for drawing limbs and landmarks.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    /// Loop through each detected pose.
    for (final pose in poses) {
      /// Draw circles for all landmarks.
      pose.landmarks.forEach((_, landmark) {
        final translatedX = translateX(
          landmark.x,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final translatedY = translateY(
          landmark.y,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        canvas.drawCircle(Offset(translatedX, translatedY), 1, paint);
      });

      /// Helper function to draw a line between two landmarks.
      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        final translatedX1 = translateX(
          joint1.x,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final translatedY1 = translateY(
          joint1.y,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final translatedX2 = translateX(
          joint2.x,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final translatedY2 = translateY(
          joint2.y,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        canvas.drawLine(
            Offset(translatedX1, translatedY1), Offset(translatedX2, translatedY2), paintType);
      }

      /// Draw lines for arms.
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      /// Draw lines for body.
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);

      /// Draw lines for legs.
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    }

    
  }
  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }


  double translateX(
      double x,
      Size canvasSize,
      Size imageSize,
      InputImageRotation rotation,
      CameraLensDirection cameraLensDirection,
      ) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x *
            canvasSize.width /
            (Platform.isIOS ? imageSize.width : imageSize.height);
      case InputImageRotation.rotation270deg:
        return canvasSize.width -
            x *
                canvasSize.width /
                (Platform.isIOS ? imageSize.width : imageSize.height);
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        switch (cameraLensDirection) {
          case CameraLensDirection.back:
            return x * canvasSize.width / imageSize.width;
          default:
            return canvasSize.width - x * canvasSize.width / imageSize.width;
        }
    }
  }

  double translateY(
      double y,
      Size canvasSize,
      Size imageSize,
      InputImageRotation rotation,
      CameraLensDirection cameraLensDirection,
      ) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y *
            canvasSize.height /
            (Platform.isIOS ? imageSize.height : imageSize.width);
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        return y * canvasSize.height / imageSize.height;
    }
  }
}

