import 'package:google_ml_kit/google_ml_kit.dart';

/// Utility class for pose detection operations using Google's ML Kit.
class PoseDetectorUtils {
  /// A static instance of [PoseDetector] initialized with default options.
  ///
  /// This detector is used for all pose detection operations in this class.
  static final PoseDetector _poseDetector =
  PoseDetector(options: PoseDetectorOptions());

  /// Detects poses in the given [InputImage].
  ///
  /// This method processes the input image using the pose detector
  /// and returns a list of detected poses.
  ///
  /// [inputImage] The image to process for pose detection.
  ///
  /// Returns a [Future] that completes with a [List] of [Pose] objects.
  static Future<List<Pose>> detectPoses(InputImage inputImage) async {
    return await _poseDetector.processImage(inputImage);
  }

  /// Closes the pose detector to free up resources.
  ///
  /// This method should be called when the pose detector is no longer needed,
  /// typically when disposing of the widget or screen that uses it.
  static void close() {
    _poseDetector.close();
  }

// Add other pose detection related methods here
}