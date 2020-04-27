import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TakePicturePage extends StatefulWidget {
  @override
  _TakePicturePageState createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String _path;

  File img;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    Utils.saveImgPath(img);

    setState(() {
      img = image;
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = CameraController(Utils.cameras[0], ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(MyLocalizations.of(context, "send_photo_title")),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: double.infinity,
              color: Colors.black,
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_path != null ? _path : ''),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      child: Icon(Icons.camera),
                      onPressed: () async {
                        // try {
                        //   await _initializeControllerFuture;
                        //   final path = join(
                        //     (await getTemporaryDirectory()).path,
                        //     '${DateTime.now()}.jpg',
                        //   );

                        //   await _controller.takePicture(path);
                        //   Utils.saveImgPath(path);
                        //   setState(() {
                        //     _path = path;
                        //   });
                        // } catch (e) {
                        //   print(e);
                        // }

                        getImage();

                        await _controller.takePicture(img.path);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
