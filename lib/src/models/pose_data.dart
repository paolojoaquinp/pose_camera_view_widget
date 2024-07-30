import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pose_camera_view/src/enums/enums.dart';

class PoseData {
  List<Pose> poses;
  PushUpState pushUpState;

  PoseData(this.poses, this.pushUpState);
}
