import 'package:camera/camera.dart';
import 'package:camera/new/camera.dart';
import 'package:flutter/material.dart';

class Utils {

  static var cameras; 
  
  static Future<void> setCameras() async {
    WidgetsFlutterBinding.ensureInitialized();

    cameras =   await availableCameras();
    
  }


  //Manage Data
  static String getLanguage() {
    return 'en';
  }
}
