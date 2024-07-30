import 'package:flutter/material.dart';
import 'package:pose_camera_view/pose_camera_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push up counter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Push up Counter Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const PushUpScreenExample()));
                },
                child: const Text('Go to the push up counter'))
          ],
        ),
      ),
    );
  }
}

class PushUpScreenExample extends StatelessWidget {
  const PushUpScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    final counterNotifier = ValueNotifier<int>(0);

    return SafeArea(
      child: Material(
        child: Stack(
          children: [
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
                }
              },
              elbowAngleMin: 60.0,
              elbowAngleMax: 160.0,
            ),
            const BackButton(),
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<int>(
                valueListenable: counterNotifier,
                builder: (context, value, child) {
                  return Text(
                    'Push-ups: $value',
                    style: const TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
