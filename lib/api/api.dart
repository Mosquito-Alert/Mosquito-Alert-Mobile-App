import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ApiSingleton {
  static String baseUrl = '';
  static String serverUrl = '';

  static final ApiSingleton _singleton = ApiSingleton._internal();

  factory ApiSingleton() {
    return _singleton;
  }

  ApiSingleton._internal();

  static Future<void> initialize() async {
    final config = await AppConfig.loadConfig();
    baseUrl = config.baseUrl;
    serverUrl = '$baseUrl/api';
  }

  static ApiSingleton getInstance() {
    return ApiSingleton();
  }

  //Reports
  Future<dynamic> createReport(Report report) async {
    // TODO: Delete?
    return null;
  }

  Future<void> createBiteReport() async {
    try {
      final position = Position(
          longitude: 0,
          latitude: 0,
          timestamp: DateTime(2025),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0);

      final LocationRequest locationRequest = LocationRequest((b) => b
        ..source_ = LocationRequestSource_Enum.auto
        ..point = LocationPoint((b) => b
          ..latitude = position.latitude
          ..longitude = position.longitude).toBuilder());

      final BiteRequest biteRequest = BiteRequest((b) => b
        ..createdAt = DateTime.now().toUtc()
        ..sentAt = DateTime.now().toUtc()
        ..location = locationRequest.toBuilder()
        ..note = "Example mosquito bite report"
        ..tags = BuiltList<String>(['sample', 'test']).toBuilder()
        ..eventEnvironment = BiteRequestEventEnvironmentEnum.outdoors
        ..eventMoment = BiteRequestEventMomentEnum.now
        ..counts = BiteCountsRequest((b) => b
          ..head = 1
          ..chest = 0).toBuilder());

      final response = await bitesApi.create(biteRequest: biteRequest);
      print('Bite report created successfully: ${response.data}');
    } catch (e) {
      print('Error creating bite report: $e');
    }
  }

  Future saveImages(Report report) async {
    if (Utils.imagePath != null) {
      Utils.imagePath!.forEach((img) async {
        if (img['id'] == report.version_UUID) {
          if (!img['image'].contains('http')) {
            var isSaved = await saveImage(img['image'], report.version_UUID);
            if (!isSaved) {
              final directory = await getApplicationDocumentsDirectory();
              File newImage = await img['imageFile']
                  .copy('${directory.path}/${report.version_UUID}.png');

              await Utils.saveLocalImage(newImage.path, report.version_UUID);
            } else {
              Utils.deleteImage(img['image']);
            }
          }
        }
      });
    }
  }

  Future<List<Report>> getReportsList() async {
    // TODO
    return [];
  }

  Future<bool> deleteBiteReport(String uuid) async {
    try {
      // TODO
      print('Deleting bite report with UUID: $uuid');
      return true;
    } catch (e) {
      print('Error deleting bite report: $e');
      return false;
    }
  }

  Future<List<Bite>> getMyBiteReports() async {
    try {
      final response = await bitesApi.listMine();
      return response.data?.results?.toList() ?? [];
    } catch (e) {
      print('Error fetching bite reports: $e');
      return [];
    }
  }

  //Images
  Future<bool> saveImage(String imagePath, String? versionUUID) async {
    try {
      // Compressing image to jpeg 4k max = 3840x2180
      Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
          imagePath,
          minWidth: 3840,
          minHeight: 2180,
          quality: 98,
          autoCorrectionAngle: true,
          format: CompressFormat.jpeg,
          keepExif: true);

      if (compressedImage == null) {
        print('Failed to compress image');
        return false;
      }

      var img = await MultipartFile.fromBytes(compressedImage,
          filename: '${path.basenameWithoutExtension(imagePath)}.jpeg',
          contentType: MediaType('image', 'jpeg'));

      var data = FormData.fromMap({'photo': img, 'report': versionUUID});
      print(data);
    } catch (c) {
      print(c);
      return false;
    }

    // TODO
    return false;
  }

  Future<dynamic> getCampaigns(countryId) async {
    // TODO
    return false;
  }
}
