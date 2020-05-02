import 'package:calorierecorder/colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:calorierecorder/bootup.dart';
import 'package:calorierecorder/cr_drawer.dart';
import 'package:calorierecorder/home.dart';

String globalUsername = 'Calorie Recorder User';
String globalUserEmail = 'Account Sync incoming...';
ImageProvider globalUserAvatar = AssetImage('assets/image/avatar.png');
double todayCalorie = 0.0;
double targetCalorie = 2500;
String todayDate = '';
List<Map<String, dynamic>> todayRecords = [];
//String modelPath = 'assets/model/food_model_101.tflite';
String modelPath = 'assets/model/food_model_101_quantized.tflite';
String labelPath = 'assets/model/food_label_101.txt';
//String modelPath = 'assets/model/food_model_128_30.tflite';
//String labelPath = 'assets/model/food_label.txt';
List<CameraDescription> cameras;
CameraController camera;
//List httpCodes = [200, 201, 400, 405, 409, 415];

class CalorieRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Recorder',
      initialRoute: '/bootup',
      routes: {
        '/': (BuildContext context) => new HomePage(),
        '/bootup': (BuildContext context) => new BootUpPage(),
        '/widgets/drawer': (BuildContext context) => new CalorieRecorderDrawer(),
      },
      onGenerateRoute: _getRoute,
      theme: clTheme,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new HomePage(),
          fullscreenDialog: true,
        );
        break;
      case '/bootup':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new BootUpPage(),
          fullscreenDialog: true,
        );
        break;
      case '/widgets/drawer':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new CalorieRecorderDrawer(),
          fullscreenDialog: false,
        );
        break;
      default:
        return null;
    }
  }
}
