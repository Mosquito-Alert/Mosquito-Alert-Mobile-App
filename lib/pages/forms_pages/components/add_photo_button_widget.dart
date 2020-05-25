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
  List<File> images = [];

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? GestureDetector(
            onTap: () {
              _showAlertImage(context);
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 10),
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
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10),
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              return index == (images.length)
                  ? GestureDetector(
                      onTap: () {
                        _showAlertImage(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(15)),
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              images[index].path,
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteImage(images[index], index);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Style.colorPrimary,
                          ),
                        ),
                      ],
                    );
            });
  }

  _showAlertImage(context) {
    if (Platform.isAndroid) {
      return showBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // backgroundColor: Colors.orange,
        elevation: 2,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 120,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                Style.title(MyLocalizations.of(context, 'add_image_txt')),
                //  Style.body(
                //       MyLocalizations.of(context, 'add_image_from_where_txt')),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        child: Style.body(
                          MyLocalizations.of(context, 'gallery'),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          getImageGallery();
                        },
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        child:
                            Style.body(MyLocalizations.of(context, 'camara')),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showInfoImage();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showCupertinoModalPopup(
        context: context, //
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Style.title(MyLocalizations.of(context, 'add_image_txt'),
                textAlign: TextAlign.center),
            // message: Style.body(
            //     MyLocalizations.of(context, 'add_image_from_where_txt')),
            actions: <Widget>[
              CupertinoActionSheetAction(
                // isDefaultAction: true,
                child: Style.body(MyLocalizations.of(context, 'gallery')),
                onPressed: () {
                  Navigator.of(context).pop();
                  getImageGallery();
                },
              ),
              CupertinoActionSheetAction(
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
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Style.body(
                    " Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently",
                  ),
                  SizedBox(
                    height: 15,
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

  _deleteImage(File img, int index) {
    Utils.deleteImage(img);
    setState(() {
      images.removeAt(index);
    });
  }

  Future getImageCamara() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    Utils.saveImgPath(image);

    setState(() {
      images.add(image);
    });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    Utils.saveImgPath(image);

    setState(() {
      images.add(image);
    });
  }
}
