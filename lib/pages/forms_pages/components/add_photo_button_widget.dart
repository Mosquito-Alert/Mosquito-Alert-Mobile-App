import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class AddPhotoButton extends StatefulWidget {
  @override
  _AddPhotoButtonState createState() => _AddPhotoButtonState();
}

class _AddPhotoButtonState extends State<AddPhotoButton> {
  File img;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showAlertImage(context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => TakePicturePage()),
        // );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                  )),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Style.titleMedium(
                        MyLocalizations.of(context, 'have_foto_txt'),
                        fontSize: 16),
                    SizedBox(
                      height: 5,
                    ),
                    Style.bodySmall(
                        MyLocalizations.of(context, 'click_to_add_txt'))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _showAlertImage(context) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Style.title(MyLocalizations.of(context, 'add_image_txt')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Style.body(
                      MyLocalizations.of(context, 'add_image_from_where_txt')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Style.body(
                  MyLocalizations.of(context, 'gallery'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  getImageGallery();
                },
              ),
              FlatButton(
                child: Style.body(MyLocalizations.of(context, 'camera')),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showInfoImage();
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context, //
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Style.title(MyLocalizations.of(context, 'add_image_txt')),
            content: Style.body(
                MyLocalizations.of(context, 'add_image_from_where_txt')),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Style.body(MyLocalizations.of(context, 'gallery')),
                onPressed: () {
                  Navigator.of(context).pop();
                  getImageGallery();
                },
              ),
              CupertinoDialogAction(
                child: Style.body(MyLocalizations.of(context, 'camara')),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showInfoImage();
                },
              ),
            ],
          );
        },
      );
    }
  }

  _showInfoImage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  Style.body(
                    " Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently",
                  ),
                  Style.noBgButton(
                    MyLocalizations.of(context, "ok_next_txt"),
                    () {
                      Navigator.of(context).pop();
                      getImageCamara();
                    },
                    textColor: Style.colorPrimary,
                  )
                ],
              ),
            ),
          );
        });
  }

  Future getImageCamara() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    Utils.saveImgPath(image);

    // setState(() {
    //   img = image;
    // });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    Utils.saveImgPath(image);

    // setState(() {
    //   img = image;
    // });
  }
}
