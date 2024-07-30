![banner](placeholder_for_banner_image.jpg)

# PoseCameraView Widget

[![build](https://img.shields.io/github/workflow/status/your_username/pose_camera_view/CI)](https://github.com/your_username/pose_camera_view/actions)
[![pose_camera_view](https://img.shields.io/pub/v/pose_camera_view?label=pose_camera_view)](https://pub.dev/packages/pose_camera_view)

Un widget de Flutter que permite detectar y analizar poses en tiempo real utilizando la cámara del dispositivo, con enfoque específico en el seguimiento de flexiones (push-ups).

## Vista previa

![Preview GIF](placeholder_for_preview_gif.gif)

## Instalación

Agrega `pose_camera_view` a las dependencias en tu archivo `pubspec.yaml`:

```yaml
dependencies:
  pose_camera_view: <última_versión>
```
Importalo en el codigo
```dart
import 'package:pose_camera_view/pose_camera_view.dart';

```
Como usar
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
### Parámetros

* onPoseData: Callback que se llama con los datos de pose detectados.
* elbowAngleMin: Ángulo mínimo del codo para considerar una flexión válida.
* elbowAngleMax: Ángulo máximo del codo para considerar una flexión válida.

### Estados de flexión

* PushUpState.init: Posición inicial de la flexión.
* PushUpState.middle: A mitad de la flexión.
* PushUpState.completed: Flexión completada.
* PushUpState.neutral: Estado neutro o no reconocido.

## Ejemplos
Para ver un ejemplo más completo, consulta la carpeta example en este repositorio.
Contribuciones
Las contribuciones son bienvenidas. Por favor, abre un issue o envía un pull request con tus sugerencias.

## Licencia
Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.