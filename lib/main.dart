import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detector_app/home_page.dart';

List<CameraDescription>? cameras;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print("${e.code}, ${e.description}");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Object Detector App',
        home: HomePage());
  }
}
