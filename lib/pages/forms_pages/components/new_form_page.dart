import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final List<File> photos;

  PreviewPage({required this.photos});

  @override
  Widget build(BuildContext context) {
    // TODO: On this page goes the new reporting form
    return Scaffold(
      appBar: AppBar(
        title: Text('Report adult'),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 200,
            width: 200,
            child: Image.file(photos[index]),
          );
        },
      ),
    );
  }
}