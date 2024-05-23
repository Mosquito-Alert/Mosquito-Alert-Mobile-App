import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:whatsapp_camera/whatsapp_camera.dart';

class CameraPage extends StatefulWidget {

  CameraPage();

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  void _openCamera() async {
    final photos = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsappCamera(
          multiple: true,
        ),
      ),
    );

    if (photos != null && photos.length >= 1 && photos.length <= 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdultReportPage(photos: photos),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}