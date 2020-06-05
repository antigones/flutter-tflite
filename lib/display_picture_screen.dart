// A widget that displays the picture taken by the user.
import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final List<dynamic> recognitions;

  const DisplayPictureScreen({Key key, this.imagePath, this.recognitions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Inference')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.file(File(imagePath)),
            Text("what is this"),
            Text("confidence")
          ],
        ));
  }
}
