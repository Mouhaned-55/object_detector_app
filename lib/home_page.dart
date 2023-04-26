import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String result = "";
  CameraController? cameraController;
  CameraImage? cameraImage;

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt");
  }

  initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController?.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController?.startImageStream((imageFormStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  cameraImage = imageFormStream,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }

  runModelOnStreamFrames() async {
    final cameraImage = this.cameraImage;
    if (cameraImage != null) {
      var sawsen = await Tflite.runModelOnFrame(
          bytesList: cameraImage.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage.height,
          imageWidth: cameraImage.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true);

      result = "";

      sawsen?.forEach((response) {
        result += response["label"] +
            " " +
            (response["confidence"] as double).toStringAsFixed(3) +
            "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 360,
                    width: 360,
                    color: Colors.white,
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      initCamera();
                    },
                    child: Container(
                      //  margin: const EdgeInsets.only(top: 35),
                      height: 360,
                      width: 360,
                      child: cameraImage == null
                          ? Container(
                              height: 360,
                              width: 360,
                              child: const Icon(Icons.photo_camera_front,
                                  color: Colors.blueAccent, size: 40),
                            )
                          : AspectRatio(
                              aspectRatio: cameraController!.value.aspectRatio,
                              child: CameraPreview(cameraController!),
                            ),
                    ),
                  ),
                )
              ],
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 55),
                child: Text(
                  result,
                  style: const TextStyle(
                      backgroundColor: Colors.black,
                      fontSize: 30.0,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
