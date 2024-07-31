![banner](https://i.imgur.com/arTQKLv.png)

# PoseCameraView Widget

[![build](https://img.shields.io/github/workflow/status/paolojoaquinp/pose_camera_view/CI)](https://github.com/paolojoaquinp/pose_camera_view/actions)
[![pose_camera_view](https://img.shields.io/pub/v/pose_camera_view?label=pose_camera_view)](https://pub.dev/packages/pose_camera_view)

A Flutter widget that allows you to detect and analyze poses in real-time using the device's camera, with a specific focus on push-up tracking.

## Preview

<img src="https://github.com/paolojoaquinp/pose_camera_view_widget/blob/master/screenshots/pose_camera_view.gif?raw=true" width="470" height="250" />

<img src="https://github.com/paolojoaquinp/pose_camera_view_widget/blob/master/screenshots/pose_camera_view1.gif?raw=true" width="250" height="470" />


## Installation

Add `pose_camera_view` to dependecies in your file `pubspec.yaml`:

```yaml
dependencies:
  pose_camera_view: <última_versión>
```
Make the import in your code.
```dart
import 'package:pose_camera_view/pose_camera_view.dart';

```
How use it
```dart
PoseCameraView(
  onPoseData: (poseData) {
    switch (poseData.pushUpState) {
      case PushUpState.middle:
        print("MIDDLE");
        break;
      case PushUpState.completed:
        print("COMPLETED");
        counterNotifier.value++;
        break;
      case PushUpState.init:
        print("INIT");
        break;
      case PushUpState.neutral:
        // Manejar este caso
        break;
    }
  },
  elbowAngleMin: 60.0,
  elbowAngleMax: 160.0,
)

```
### Parameters

* onPoseData: Callback that is called with the detected pose data.
* elbowAngleMin: Minimum elbow angle to consider a valid flexion.
* elbowAngleMax: Maximum elbow angle to consider a valid flexion.

### Push Up states

* PushUpState.init: Initial position of pushup.
* PushUpState.middle: Halfway through pushup.
* PushUpState.completed: Pushup completed.

## Examples
For a more complete example, see the example folder in this repository.
Contributions
Contributions are welcome. Please open an issue or send a pull request with your suggestions.

## License
This project is licensed under the MIT License - see the LICENSE file for more details.