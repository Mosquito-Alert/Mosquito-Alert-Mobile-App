import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPhotoButton extends StatefulWidget {
  final bool isEditing;
  final bool photoRequired;
  final List<File> photos;

  AddPhotoButton(this.isEditing, this.photoRequired, this.photos);

  @override
  _AddPhotoButtonState createState() => _AddPhotoButtonState(photos: photos);
}

class _AddPhotoButtonState extends State<AddPhotoButton> {
  List<File> photos;

  _AddPhotoButtonState({required this.photos});

  @override
  void initState() {
    _permissionsPath();
    super.initState();
    addAllPreviousPhotosToUtil(photos);
  }

  void addAllPreviousPhotosToUtil(List<File> photos){
    // TODO: Insert photos into Utils.report because this is what is sent to the API
    for (var i = 0; i < photos.length; i++){
      addPhotoToUtil(photos[i]);
    }
  }

  void addPhotoToUtil(File photo){
    var p = Photo(id: null, photo: photo.path, uuid: null);
    if (Utils.report!.photos == null){
      Utils.report!.photos ??= [];
    }    
    Utils.report!.photos!.add(p);
  }

  void removePhotoFromUtil(File photo){
    Utils.report!.photos!.removeWhere((p) => p.photo == photo.path);
  }

  void _permissionsPath() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),      
      child: Column(children: [
        SizedBox(
          height: 40,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
          itemCount: min(3, photos.length + 1),
          itemBuilder: (context, index) {
            return index == (photos.length)
              ? squareToAddPhoto()
              : squareWithPhoto(index);
          }
        ),
      ],
      )
    );
  }

  Widget squareToAddPhoto() {
    return GestureDetector(
      onTap: () {
        _chooseTypeImage();
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
    );
  }

  Widget squareWithPhoto(int index){
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(photos[index]),
            ),
        ),
        Container(
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
                _deletePhoto(index);
              },
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _chooseTypeImage() {
    var listForiOS = <Widget>[
      CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
          getGalleryImages();
        },
        child: Text(
          MyLocalizations.of(context, 'gallery')!,
          style: TextStyle(color: Colors.blue),
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          if (Utils.report!.type == 'adult') {
            Utils.infoAdultCamera(context, getImage);
          } else if (Utils.report!.type == 'site') {
            Utils.infoBreedingCamera(context, getImage);
          }
          Navigator.pop(context);
        },
        child: Text(
          MyLocalizations.of(context, 'camara')!,
          style: TextStyle(color: Colors.blue),
        ),
      ),
    ];
    var listForAndroid = <Widget>[
      InkWell(
        onTap: () {
          if (Utils.report!.type == 'adult') {
            Utils.infoAdultCamera(context, getImage);
          } else if (Utils.report!.type == 'site') {
            Utils.infoBreedingCamera(context, getImage);
          }
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Text(MyLocalizations.of(context, 'camara')!,
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
          child: Text(MyLocalizations.of(context, 'gallery')!,
              style: TextStyle(color: Colors.blue, fontSize: 15)),
        ),
      ),
    ];

    Utils.modalDetailTrackingforPlatform(
        Theme.of(context).platform == TargetPlatform.iOS
            ? listForiOS
            : listForAndroid,
        Theme.of(context).platform,
        context, () {
      Navigator.pop(context);
    }, title: '${MyLocalizations.of(context, 'bs_info_adult_title')}:');
  }

  void _deletePhoto(int index) {
    if (widget.photoRequired && photos.length == 1) {
      Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'photo_required_alert'), context);
    } else {
      if (index < photos.length) {
        setState(() {
          photos.removeAt(index);
        });
      }
    }
  }

  void getGalleryImages() async {
    var newFiles = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (newFiles != null && newFiles.files.isNotEmpty) {
      var selectedFiles = newFiles.files.map((file) => File(file.path!)).toList();

      selectedFiles.forEach((file) {
        Utils.saveImgPath(file);
      });

      setState(() {
        photos.addAll(selectedFiles);
      });
    }
  }

  Future getImage(source) async {
    if (await Permission.camera.isPermanentlyDenied && Platform.isIOS) {
      await openAppSettings();
      return;
    }

    final _picker = ImagePicker();
    var image = await _picker.pickImage(
        source: source, maxHeight: 1024, imageQuality: 60);
    if (image != null) {
      final file = File(image.path);
      setState(() {
        photos.add(file);
      });
      Utils.saveImgPath(file);
    }
  }
}
