import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pose_camera_view/src/src.dart';

class PoseCameraView extends StatefulWidget {
  final void Function(PoseData) onPoseData;
  final CameraLensDirection initialCameraLensDirection;
  final double elbowAngleMin;
  final double elbowAngleMax;

  const PoseCameraView({
    super.key,
    required this.onPoseData,
    this.initialCameraLensDirection = CameraLensDirection.front,
    this.elbowAngleMin = 60.0,
    this.elbowAngleMax = 150.0,
  });

  @override
  _PoseCameraViewState createState() => _PoseCameraViewState();
}

class _PoseCameraViewState extends State<PoseCameraView> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;
  CameraLensDirection _cameraLensDirection = CameraLensDirection.front;

  final ValueNotifier<bool> _canProcess = ValueNotifier(true);
  final ValueNotifier<bool> _isBusy = ValueNotifier(false);
  final ValueNotifier<String> _text = ValueNotifier('');

  final ValueNotifier<PoseData> _poseDataNotifier =
  ValueNotifier(PoseData([], PushUpState.init));
  final ValueNotifier<CustomPaint?> _customPaintNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _canProcess.dispose();
    _isBusy.dispose();
    _text.dispose();
    _poseDataNotifier.dispose();
    _customPaintNotifier.dispose();
    PoseDetectorUtils.close();
    _stopLiveFeed();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  Future<void> _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller =
    await CameraControllerUtils.initializeCameraController(camera);

    // Get the camera's capabilities
    _minAvailableZoom = await _controller!.getMinZoomLevel();
    _maxAvailableZoom = await _controller!.getMaxZoomLevel();
    _currentZoomLevel = _minAvailableZoom;

    _minAvailableExposureOffset = await _controller!.getMinExposureOffset();
    _maxAvailableExposureOffset = await _controller!.getMaxExposureOffset();
    _currentExposureOffset = 0.0;

    _controller!.startImageStream(_processCameraImage);
    setState(() {});
  }

  Future<void> _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future<void> _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    _cameraLensDirection = _cameras[_cameraIndex].lensDirection;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = CameraControllerUtils.inputImageFromCameraImage(
      image,
      _controller!,
      _cameras[_cameraIndex],
    );
    if (inputImage == null) return;
    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess.value || _isBusy.value) return;
    _isBusy.value = true;
    _text.value = '';

    try {
      final poses = await PoseDetectorUtils.detectPoses(inputImage);
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );

      _customPaintNotifier.value = CustomPaint(painter: painter);
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        for (final pose in poses) {
          final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
          final elbow = pose.landmarks[PoseLandmarkType.rightElbow];
          final wrist = pose.landmarks[PoseLandmarkType.rightWrist];

          if (shoulder != null && elbow != null && wrist != null) {
            final elbowAngle = Utils.angle(shoulder, elbow, wrist);
            final newState = Utils.isPushUp(
                elbowAngle,
                _poseDataNotifier.value.pushUpState,
                widget.elbowAngleMin,
                widget.elbowAngleMax);
            if (newState != null) {
              if (newState == PushUpState.completed) {
                _poseDataNotifier.value =
                    PoseData(poses, PushUpState.completed);
                widget.onPoseData(_poseDataNotifier.value);
                _poseDataNotifier.value = PoseData(poses, PushUpState.init);
                widget.onPoseData(_poseDataNotifier.value);
              } else {
                _poseDataNotifier.value = PoseData(poses, newState);
                widget.onPoseData(_poseDataNotifier.value);
              }
            }
          }
        }
      } else {
        _text.value = 'Poses found: ${poses.length}';
        _customPaintNotifier.value = null;
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isBusy.value = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _setZoomLevel(double zoomLevel) async {
    if (_controller == null) return;

    try {
      await _controller!.setZoomLevel(zoomLevel);
      setState(() {
        _currentZoomLevel = zoomLevel;
      });
    } catch (e) {
      print('Error setting zoom level: $e');
    }
  }

  Future<void> _setExposureOffset(double offset) async {
    if (_controller == null) return;

    try {
      await _controller!.setExposureOffset(offset);
      setState(() {
        _currentExposureOffset = offset;
      });
    } catch (e) {
      print('Error setting exposure offset: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<CustomPaint?>(
        valueListenable: _customPaintNotifier,
        builder: (context, customPaint, child) {
          return ValueListenableBuilder<PoseData>(
            valueListenable: _poseDataNotifier,
            builder: (context, poseData, _) {
              if (_controller == null) return Container();
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Center(
                    child: _changingCameraLens
                        ? const Center(child: Text('Changing camera lens'))
                        : CameraPreview(
                      _controller!,
                      child: customPaint,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: FloatingActionButton(
                      onPressed: _switchLiveCamera,
                      child: const Icon(Icons.flip_camera_ios),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Zoom: ${_currentZoomLevel.toStringAsFixed(1)}x',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Slider(
                          value: _currentZoomLevel,
                          min: _minAvailableZoom,
                          max: _maxAvailableZoom,
                          onChanged: (value) => _setZoomLevel(value),
                        ),
                        Text(
                          'Exposure: ${_currentExposureOffset.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Slider(
                          value: _currentExposureOffset,
                          min: _minAvailableExposureOffset,
                          max: _maxAvailableExposureOffset,
                          onChanged: (value) => _setExposureOffset(value),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Text(
                      'Push-up State: ${poseData.pushUpState}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

