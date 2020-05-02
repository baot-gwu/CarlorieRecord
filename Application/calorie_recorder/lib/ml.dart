import 'package:calorierecorder/app.dart';
import 'package:calorierecorder/utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:calorierecorder/colors.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String _model = '';
  double _imageHeight = 128.0;
  double _imageWidth = 128.0;
  bool _busy = false;
  bool _modelLoaded = false;
  bool _isDetecting = false;
  bool _isStreaming = true;
  bool _built = false;
  bool _cameraInited = false;
  List<Map<String, dynamic>> _recognitions = [];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text('ML Food Detection'),
        ),
        body: Column(
          children: [
//          Container(
//            width: size,
//            height: size,
//            child: (_isStreaming)? CameraPreview(
//              camera,
//            ) : Container(),
//          ),
            FutureBuilder<void>(
              future: initCamera(),
              builder: (context, snapshot) {
                if (_isStreaming ||
                    snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      Transform.scale(
                        scale: 0.85,
                        child: Container(
                          width: size ?? MediaQuery.of(context).size.width,
                          height: size ?? MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(size / 2),
                            child: OverflowBox(
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Container(
                                  width: size,
                                  height: size / camera.value.aspectRatio,
                                  child: (_isStreaming)
                                      ? CameraPreview(
                                          camera,
                                        )
                                      : Container(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container(
                      height: size,
                      child: Center(child: CircularProgressIndicator()));
                }
              },
            ),
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity, // match_parent
                      child: RaisedButton(
                        child: Text(_isStreaming ? 'Freeze' : 'Retake'),
                        onPressed: () {
                          if (_isStreaming) {
                            camera.stopImageStream();
                          } else {
                            startCameraStreaming();
                          }
                          setState(() {
                            _isStreaming = !_isStreaming;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity, // match_parent
                      child: RaisedButton(
                        child: Text('Gallery'),
                        onPressed: () {
                          predictImagePicker();
                        },
                      ),
                    ),
                  ],
                ),
                _buildResultsWidget(size, _recognitions)
              ],
            ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    _busy = true;

    initTF().then((val) {
      setState(() {
        _modelLoaded = true;
        _busy = false;
      });
    });

    camera = CameraController(cameras[0], ResolutionPreset.high);
    camera.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraInited = true;
      });
    });
  }

  @override
  void dispose() {
    camera?.dispose();
    super.dispose();
  }

  Future initTF() async {
//    await Tflite.close();
    try {
      String res = await Tflite.loadModel(
          model: modelPath, labels: labelPath, numThreads: 4 // defaults to 1
          );
      _modelLoaded = true;
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  Future detection(CameraImage img) async {
    if (img.width == null || img.height == null) return;
    var recognitions = await Tflite.runModelOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            // required
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 0,
            // defaults to 127.5
            imageStd: 255,
            // defaults to 127.5
            rotation: 90,
            // defaults to 90, Android only
            numResults: 5,
            // defaults to 5
            threshold: 0.1,
            // defaults to 0.1
            asynch: true // defaults to true
            )
        .then((value) {
//          debugPrint("detection!");
      if (value.isNotEmpty) {
        debugPrint(value.toString());
        _recognitions.clear();
        value.forEach((element) {
          _recognitions.add({
            "confidence": element['confidence'],
            "index": element['index'],
            "label": element['label']
          });
        });
      }
    });

    _recognitions.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    setState(() {
      _isDetecting = false;
    });
  }

  Future detectionbyImage(File img) async {
    if (img == null) return;
    var recognitions = await Tflite.runModelOnImage(
        path: img.path,
        // required
        imageMean: 0.0,
        // defaults to 117.0
        imageStd: 255.0,
        // defaults to 1.0
        numResults: 5,
        // defaults to 5
        threshold: 0.1,
        // defaults to 0.1
        asynch: true // defaults to true
        ).then((value) {
//          debugPrint("detection!");
      if (value.isNotEmpty) {
        debugPrint(value.toString());
        _recognitions.clear();
        value.forEach((element) {
          _recognitions.add({
            "confidence": element['confidence'],
            "index": element['index'],
            "label": element['label']
          });
        });
      }
    });

    _recognitions.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    setState(() {
      _isDetecting = false;
    });
  }

  Future predictImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    detectionbyImage(image);
  }

  Future initCamera() async {
    if (!camera.value.isInitialized) {
      return;
    }
    if (!_built) {
      _built = true;
      return camera.initialize().then((value) {
        startCameraStreaming();
      });
    } else {
      return camera;
    }
  }

  Widget _buildResultsWidget(double width, List<Map<String, dynamic>> outputs) {
    return Container(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 300.0,
          width: width,
          color: Colors.white,
          child: outputs != null && outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      children: [
                        Column(
                          children: <Widget>[
                            Text(
                              outputs[index]['label'],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              "${(outputs[index]['confidence'] * 100.0).toStringAsFixed(2)} %",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        )

                      ],
                    );
                  })
              : Center(
                  child: Text("Wating for model to detect..",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ))),
        ),
      ),
    );
  }

  void startCameraStreaming() {
    camera.startImageStream((CameraImage image) {
//      debugPrint("modelLoaded: ${_modelLoaded.toString()}");
//      debugPrint("isDetecting: ${_isDetecting.toString()}");
      if (!_modelLoaded) return;
      if (_isDetecting) return;
      _isDetecting = true;
      if (image.height == null || image.width == null) return;
      try {
        detection(image);
      } catch (e) {
        print(e);
      }
    });
  }
}
