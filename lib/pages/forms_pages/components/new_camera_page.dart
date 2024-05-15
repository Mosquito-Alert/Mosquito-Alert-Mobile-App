import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_camera/whatsapp_camera.dart';


class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    // Open camera on page start
    openCamera();
  }

  void openCamera() async {
    // Implement camera opening logic
    // After taking/selecting photos, navigate to PreviewPage with the photos
    final List<File> res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WhatsappCamera(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your CameraPage UI here
    );
  }
}