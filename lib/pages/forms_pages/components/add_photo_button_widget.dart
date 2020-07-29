import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:photo_view/photo_view.dart';

class AddPhotoButton extends StatefulWidget {
  @override
  _AddPhotoButtonState createState() => _AddPhotoButtonState();
}

class _AddPhotoButtonState extends State<AddPhotoButton> {
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    // _chooseTypeImage();
    if (Utils.imagePath != null && Utils.imagePath.isNotEmpty) {
      Utils.imagePath.forEach((element) {
        if (element['id'] == Utils.report.version_UUID) {
          images.add(element['image']);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? GestureDetector(
            onTap: () {
              _chooseTypeImage();
            },
            child: Card(
              margin: EdgeInsets.only(bottom: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                // child: Row(
                //   children: <Widget>[
                //     Container(
                //         padding:
                //             EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                //         child: Icon(
                //           Icons.camera_alt,
                //           size: 40,
                //         )),
                //     Expanded(
                //       flex: 2,
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: <Widget>[
                //           Style.titleMedium(
                //               MyLocalizations.of(context, 'have_foto_txt'),
                //               fontSize: 16),
                //           SizedBox(
                //             height: 5,
                //           ),
                //           Style.bodySmall(
                //               MyLocalizations.of(context, 'click_to_add_txt'))
                //         ],
                //       ),
                //     )
                //   ],
                // ),
              ),
            ),
          )
        : Container(
            margin: EdgeInsets.only(bottom: 15),
            child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: images.length + 1,
                itemBuilder: (context, index) {
                  return index == (images.length)
                      ? GestureDetector(
                          onTap: () {
                            _chooseTypeImage();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1),
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
                                child: Image.file(
                                  images[index],
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: 100,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showImage(images[index].path);
                              },
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black54,
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.center,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                    onPressed: () {
                                      _deleteImage(images[index], index);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                }),
          );
  }

  _showImage(image) {
    return Container(
        height: 700,
        width: 700,
        child: PhotoView(
          imageProvider: AssetImage(image),
        ));
  }

  _chooseTypeImage() {
    List<Widget> listForiOS = <Widget>[
      CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
          getGalleryImages();
        },
        child: Text(
          MyLocalizations.of(context, 'gallery'),
          style: TextStyle(color: Colors.blue),
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          if (Utils.report.type == 'adult') {
            Utils.infoAdultCamera(context, getImage);
          } else if (Utils.report.type == 'site') {
            Utils.infoBreedingCamera(context, getImage);
          }
          Navigator.pop(context);
        },
        child: Text(
          MyLocalizations.of(context, 'camara'),
          style: TextStyle(color: Colors.blue),
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          MyLocalizations.of(context, 'continue_without_photo'),
          style: TextStyle(color: Colors.blue),
        ),
      ),
    ];
    List<Widget> listForAndroid = <Widget>[
      InkWell(
        onTap: () {
          if (Utils.report.type == 'adult') {
            Utils.infoAdultCamera(context, getImage);
          } else if (Utils.report.type == 'site') {
            Utils.infoBreedingCamera(context, getImage);
          }
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Text(MyLocalizations.of(context, 'camara'),
              style: TextStyle(color: Colors.blue, fontSize: 15)),
        ),
      ),
      Divider(height: 1.0),
      InkWell(
        onTap: () {
          Navigator.pop(context);
          getGalleryImages();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Text(MyLocalizations.of(context, 'gallery'),
              style: TextStyle(color: Colors.blue, fontSize: 15)),
        ),
      ),
      Utils.report.type == 'adult'
          ? Column(
              children: <Widget>[
                Divider(height: 1.0),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Text(
                        MyLocalizations.of(context, 'continue_without_photo'),
                        style: TextStyle(color: Colors.blue, fontSize: 15)),
                  ),
                ),
              ],
            )
          : Container(),
    ];

    Utils.modalDetailTrackingforPlatform(
        Theme.of(context).platform == TargetPlatform.iOS
            ? listForiOS
            : listForAndroid,
        Theme.of(context).platform,
        context, () {
      Navigator.pop(context);
    });
  }

  _deleteImage(File img, int index) {
    Utils.deleteImage(img);
    setState(() {
      images.removeAt(index);
    });
  }

  getGalleryImages() async {
    List<File> files = await FilePicker.getMultiFile(
      type: FileType.image,
    );

    if (files != null) {
      files.forEach((image) {
        Utils.saveImgPath(image);
      });

      setState(() {
        images = [...images, ...files];
      });
    }
  }

  Future getImage(source) async {
    var image = await ImagePicker.pickImage(
      source: source,
    );

    if (image != null) {
      Utils.saveImgPath(image);

      setState(() {
        images.add(image);
      });
    }
  }
}
