import 'package:google_ml_kit/google_ml_kit.dart';

class PoseDetectorUtils {
  static final PoseDetector _poseDetector =
  PoseDetector(options: PoseDetectorOptions());

  static Future<List<Pose>> detectPoses(InputImage inputImage) async {
    return await _poseDetector.processImage(inputImage);
  }

  static void close() {
    _poseDetector.close();
  }

// Add other pose detection related methods here
}