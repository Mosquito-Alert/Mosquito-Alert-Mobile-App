import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

class _WhatsAppCameraController extends ChangeNotifier {
  ///
  /// don't necessary to use this class
  /// this is the class to controller the actions
  ///
  _WhatsAppCameraController({this.multiple = true});

  /// permission to select multiple images
  ///
  /// multiple => default is true
  ///
  ///
  ///
  final bool multiple;
  final selectedImages = <File>[];
  var images = <Medium>[];

  Future<void> loadRecentGalleryImages() async {
    if (Platform.isIOS)
      return; // Functionality of album.listMedia() crashes on iOS

    final status = await Permission.photos.request();
    if (status.isDenied) return;
    if (status.isPermanentlyDenied) return;

    try {
      final albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      if (albums.isEmpty) return;

      final recentAlbum = albums.first;
      final media = await recentAlbum.listMedia(
        skip: 0,
        take: 10,
      );

      images = media.items;
      notifyListeners();
    } catch (e) {
      print('Error loading gallery images: $e');
    }
  }

  Future<void> openGallery() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: multiple,
      type: FileType.image,
    );
    if (res != null) {
      for (var element in res.files) {
        if (element.path != null) selectedImages.add(File(element.path!));
      }
    }
  }

  void captureImage(File file) {
    selectedImages.add(file);
  }
}

class WhatsappCamera extends StatefulWidget {
  /// permission to select multiple images
  ///
  /// multiple => default is true
  ///
  ///
  ///how use:
  ///```dart
  ///List<File>? res = await Navigator.push(
  /// context,
  /// MaterialPageRoute(
  ///   builder: (context) => const WhatsappCamera()),
  ///);
  ///
  ///```
  ///
  final bool multiple;
  final String? infoBadgeTextKey;

  /// how use:
  ///```dart
  ///List<File>? res = await Navigator.push(
  /// context,
  /// MaterialPageRoute(
  ///   builder: (context) => const WhatsappCamera()),
  ///);
  ///
  ///```
  ///
  const WhatsappCamera({key, this.multiple = true, this.infoBadgeTextKey = ''});

  @override
  State<WhatsappCamera> createState() => _WhatsappCameraState();
}

class _WhatsappCameraState extends State<WhatsappCamera>
    with WidgetsBindingObserver {
  late _WhatsAppCameraController controller;
  final painel = SlidingUpPanelController();
  bool _isCameraPermissionGranted = false;

  @override
  void dispose() {
    controller.dispose();
    painel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = _WhatsAppCameraController(multiple: widget.multiple);
    _requestCameraPermission();
    painel.addListener(() {
      if (painel.status.name == 'hidden') {
        controller.selectedImages.clear();
      }
    });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    if (status.isGranted) {
      controller.loadRecentGalleryImages();
    }
  }

  Widget _buildCameraPermissionDeniedScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  MyLocalizations.of(context, 'camera_permission_required'),
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (await openAppSettings()) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(MyLocalizations.of(context, 'open_settings')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return _buildCameraPermissionDeniedScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // TODO: Replace camera
          /*CameraCamera(
            enableZoom: false,
            resolutionPreset: ResolutionPreset.high,
            cameraSide: CameraSide.front,
            onFile: (file) {
              controller.captureImage(file);
              Navigator.pop(context, controller.selectedImages);
            },
          ),*/
          onlyOneMosquitoBadge(context, widget),
          closeButton(context),
          galleryButton(context, controller),
          recentPhotosStrip(context, controller),
        ],
      ),
    );
  }
}

Widget onlyOneMosquitoBadge(BuildContext context, dynamic widget) {
  return Visibility(
    visible: widget.infoBadgeTextKey != null,
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Container(
            width: 0.5 * MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.orange.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              heightFactor: 1.5,
              child: Text(MyLocalizations.of(context, widget.infoBadgeTextKey),
                  style: TextStyle(color: Colors.white)),
            )),
      ),
    ),
  );
}

Widget closeButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          color: Colors.white,
          onPressed: (() => Navigator.pop(context)),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
}

Widget galleryButton(
    BuildContext context, _WhatsAppCameraController controller) {
  return SafeArea(
    minimum: const EdgeInsets.only(bottom: 0),
    child: Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32, right: 64),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black.withValues(alpha: 0.6),
          child: IconButton(
            color: Colors.white,
            onPressed: () async {
              // Request permission when gallery button is tapped
              final status = await Permission.photos.request();
              if (status.isPermanentlyDenied) {
                // Open app settings if permanently denied
                await openAppSettings();
                return;
              }

              await controller.openGallery().then((value) {
                if (controller.selectedImages.isNotEmpty) {
                  Navigator.pop(context, controller.selectedImages);
                }
              });
            },
            icon: const Icon(Icons.image),
          ),
        ),
      ),
    ),
  );
}

Widget recentPhotosStrip(
    BuildContext context, _WhatsAppCameraController controller) {
  if (Platform.isIOS) return Container();

  return FutureBuilder<PermissionStatus>(
    future: Permission.photos.status,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data != PermissionStatus.granted) {
        return Container();
      }

      return Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Container(
          height: 90,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.images.isEmpty) {
                return Container();
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.images.length,
                itemBuilder: (context, index) {
                  final medium = controller.images[index];
                  return FutureBuilder<Widget>(
                    future: _buildImage(context, controller, medium),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return snapshot.data!;
                      }
                      return Container();
                    },
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}

Future<Widget> _buildImage(BuildContext context,
    _WhatsAppCameraController controller, Medium medium) async {
  final List<int> thumbnailData = await medium.getThumbnail(
    width: 200,
    height: 200,
    highQuality: true,
  );

  final Uint8List thumbnail = Uint8List.fromList(thumbnailData);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: GestureDetector(
      onTap: () async {
        final file = await medium.getFile();
        controller.captureImage(file);
        Navigator.pop(context, controller.selectedImages);
      },
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            thumbnail,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );
}
