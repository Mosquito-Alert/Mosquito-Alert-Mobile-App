import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/new_form_page.dart';
import 'package:whatsapp_camera/whatsapp_camera.dart';

class NewAdultReportPage extends StatefulWidget {

  NewAdultReportPage();

  @override
  _NewAdultReportPageState createState() => _NewAdultReportPageState();
}

class _NewAdultReportPageState extends State<NewAdultReportPage> {
  void _openCamera() async {
    final List<File>? photos = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsappCamera(
          multiple: true,
        ),
      ),
    );

    if (photos != null && photos.isNotEmpty) {
      // Pass the list of photos to the PreviewPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(photos: photos),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a picture'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Opening camera...'),
      ),
    );
  }
}