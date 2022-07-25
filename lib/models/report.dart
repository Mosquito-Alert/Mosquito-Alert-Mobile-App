import 'dart:convert';
import 'dart:developer';

import 'package:mosquito_alert_app/models/question.dart';

class Report {
  String version_UUID;
  int version_number;
  String user;
  String report_id;
  String phone_upload_time;
  String creation_time;
  String version_time;
  String type;
  String location_choice;
  double current_location_lon;
  double current_location_lat;
  double selected_location_lon;
  double selected_location_lat;
  String note;
  String package_name;
  int package_version;
  int session;
  List<Photo> photos;
  List<Question> responses;
  String device_manufacturer;
  String device_model;
  String os;
  String os_version;
  String os_language;
  String app_language;
  String displayCity;
  int country;
  String nuts3;
  String nuts2;
  bool offline;

  Report(
      {this.version_UUID,
      this.version_number,
      this.user,
      this.report_id,
      this.phone_upload_time,
      this.creation_time,
      this.version_time,
      this.type,
      this.location_choice,
      this.current_location_lon,
      this.current_location_lat,
      this.selected_location_lon,
      this.selected_location_lat,
      this.note,
      this.package_name,
      this.package_version,
      this.session,
      this.responses,
      this.device_manufacturer,
      this.device_model,
      this.os,
      this.os_language,
      this.os_version,
      this.app_language,
      this.displayCity,
      this.nuts3,
      this.offline,
      this.nuts2,
      this.country});

  Report.fromJson(Map<dynamic, dynamic> json) {
    version_UUID = json['version_UUID'].toString();
    version_number = json['version_number'];
    user = json['user'].toString();
    report_id = json['report_id'].toString();
    phone_upload_time = json['phone_upload_time'].toString();
    creation_time = json['creation_time'].toString();
    version_time = json['version_time'].toString();
    type = json['type'].toString();
    location_choice = json['location_choice'].toString();
    current_location_lon = json['current_location_lon'];
    current_location_lat = json['current_location_lat'];
    selected_location_lon = json['selected_location_lon'];
    selected_location_lat = json['selected_location_lat'];
    note = json['note'].toString();
    package_name = json['package_name'].toString();
    package_version = json['package_version'];
    session = json['session'];

    if (json['photos'] != null) {
      photos = <Photo>[];
      json['photos'].forEach((p) {
        var ph = Photo.fromJson(p);
        photos.add(ph);
      });
    }

    if (json['responses'] != null) {
      responses = <Question>[];
      json['responses'].forEach((q) {
        responses.add(Question.fromJson(q));
      });
    }

    device_manufacturer = json['device_manufacturer'];
    device_model = json['device_model'];
    os = json['os'];
    os_version = json['os_version'];
    os_language = json['os_language'];
    app_language = json['app_language'];
    country = json['country'];
    nuts3 = json['nuts_3'];
    nuts2 = json['nuts_2'];
    isUploaded = json['offline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['version_UUID'] = version_UUID;
    data['version_number'] = version_number;
    data['user'] = user;
    data['report_id'] = report_id;
    data['phone_upload_time'] = phone_upload_time;
    data['creation_time'] = creation_time;
    data['version_time'] = version_time;
    data['type'] = type;
    data['location_choice'] = location_choice;
    data['current_location_lon'] = current_location_lon;
    data['current_location_lat'] = current_location_lat;
    data['selected_location_lon'] = selected_location_lon;
    data['selected_location_lat'] = selected_location_lat;
    data['note'] = note;
    data['package_name'] = package_name;
    data['package_version'] = package_version;
    data['session'] = session;

    if (responses != null) {
      data['responses'] = responses.map((r) => r.toJson()).toList();
    }

    if (photos != null) {
      data['photos'] = photos.map((r) => r.toJson()).toList();
    }

    data['device_manfacturer'] = this.device_manufacturer;
    data['device_model'] = this.device_model;
    data['os'] = this.os;
    data['os_version'] = this.os_version;
    data['os_language'] = this.os_language;
    data['app_language'] = this.app_language;
    data['offline'] = this.isUploaded;
    return data;
  }

  static Map<String, dynamic> toMap(Report report) => {
        'version_UUID': report.version_UUID,
        'version_number': report.version_number,
        'user': report.user,
        'report_id': report.report_id,
        'phone_upload_time': report.phone_upload_time,
        'creation_time': report.creation_time,
        'version_time': report.version_time,
        'type': report.type,
        'location_choice': report.location_choice,
        'current_location_lon': report.current_location_lon,
        'current_location_lat': report.current_location_lat,
        'selected_location_lon': report.selected_location_lon,
        'selected_location_lat': report.selected_location_lat,
        'note': report.note,
        'package_name': report.package_name,
        'package_version': report.package_version,
        'session': report.session,
        'photos': report.photos,
        'responses': report.responses,
        'device_manufacturer': report.device_manufacturer,
        'device_model': report.device_model,
        'os': report.os,
        'os_version': report.os_version,
        'os_language': report.os_language,
        'app_language': report.app_language,
        'displayCity': report.displayCity,
        'country': report.country,
        'nuts3': report.nuts3,
        'nuts2': report.nuts2,
        'offline': report.offline,
      };

  static String encode(List<Report> reports) => json.encode(
        reports
            .map<Map<String, dynamic>>((report) => Report.toMap(report))
            .toList(),
      );

  static List<Report> decode(String reports) {
    return (json.decode(reports) as List<dynamic>)
        .map<Report>((item) => Report.fromJson(item))
        .toList();
  }
}

class Photo {
  String id;
  String photo;
  String uuid;

  Photo({
    this.id,
    this.photo,
    this.uuid,
  });

  Photo.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'].toString();
    photo = json['photo'].toString();
    uuid = json['uuid'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['photo'] = photo;
    data['uuid'] = uuid;
    return data;
  }
}
