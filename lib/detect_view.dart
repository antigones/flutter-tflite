import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class DetectView extends StatefulWidget {
  final CameraDescription camera;

  DetectView({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _DetectViewState createState() => _DetectViewState();
}

class _DetectViewState extends State<DetectView> {
  var modelLoaded = false;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isDetecting = false;
  List _predictions = List();
  Future<String> loadModel() async {
    return Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.

    loadModel().then((val) {
      setState(() {
        modelLoaded = true;
      });
      _initCamera();
    });
  }

  void _initCamera() {
    _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.high,
        enableAudio: false);
    _initializeControllerFuture = _controller.initialize().then((value) => {
          _controller.startImageStream((CameraImage image) {
            if (!modelLoaded) return;
            if (isDetecting) return;
            isDetecting = true;
            try {
              runModel(image);
            } catch (e) {
              print(e);
            }
          })
        });
  }

  Future runModel(CameraImage image) async {
    await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            numResults: 10)
        .then((values) {
      if (values.isNotEmpty) {
        //Do something with the results
        values.sort((a, b) => a['confidence'].compareTo(b['confidence']));
        print(values);
        setState(() {
          //Set bit to false to allow detection again
          isDetecting = false;
          _predictions = values;
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  String _getPredictionText() {
    if (_predictions.length > 0) {
      print(_predictions);
      var bestPrediction = _predictions.last;
      return bestPrediction['label'];
    }
    return "Prediction will appear here";
  }

  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);*/
    return Scaffold(
        appBar: AppBar(title: Text('Take a picture')),
        // Wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner
        // until the controller has finished initializing.
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return Stack(
                children: <Widget>[
                  CameraPreview(_controller),
                  Text(
                    _getPredictionText(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  )
                ],
              );
              //return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
