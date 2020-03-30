import 'package:camera/camera.dart';

class Utils {
  static List<CameraDescription> cameras;

  static String imagePath; 

  
  static void saveImgPath(String path){
    imagePath = path;
  }

  static String getImagePath(){
    return imagePath;
  }

  //Manage Data
  static String getLanguage() {
    return 'en';
  }
}
