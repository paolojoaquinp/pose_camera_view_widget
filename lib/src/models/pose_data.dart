import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pose_camera_view/src/enums/enums.dart';

/// Represents the data model for pose detection results.
class PoseData {
  /// A list of detected poses.
  ///
  /// Each [Pose] in this list represents a set of detected body landmarks
  /// for a single person in the image.
  final List<Pose> poses;

  /// The current state of the push-up exercise.
  ///
  /// This indicates the stage of the push-up (init, middle, or completed)
  /// based on the detected pose.
  final PushUpState pushUpState;

  /// Creates a new [PoseData] instance.
  ///
  /// [poses] is a list of detected poses from the ML Kit.
  /// [pushUpState] represents the current state of the push-up exercise.
  PoseData(this.poses, this.pushUpState);
}