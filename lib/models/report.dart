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
  String package_version;
  int session;
  List<Photo> photos;
  List<Question> responses;

  Report({
    this.version_UUID,
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
    // this.photos,
    this.responses,
  });

  Report.fromJson(Map<dynamic, dynamic> json) {
    version_UUID = json['version_UUID'];
    version_number = json['version_number'];
    user = json['user'];
    report_id = json['report_id'];
    phone_upload_time = json['phone_upload_time'];
    creation_time = json['creation_time'];
    version_time = json['version_time'];
    type = json['type'];
    location_choice = json['location_choice'];
    current_location_lon = json['current_location_lon'];
    current_location_lat = json['current_location_lat'];
    selected_location_lon = json['selected_location_lon'];
    selected_location_lat = json['selected_location_lat'];
    note = json['note'];
    package_name = json['package_name'];
    package_version = json['package_version'];
    session = json['session'];

    if (json['photos'] != null) {
      var jj = json['photos'];
      print(jj);
      photos = <Photo>[];
      json['photos'].forEach((p) {
        var ph = new Photo.fromJson(p);
        photos.add(ph);
      });
    }

    if (json['responses'] != null) {
      responses = <Question>[];
      json['responses'].forEach((q) {
        responses.add(new Question.fromJson(q));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version_UUID'] = this.version_UUID;
    data['version_number'] = this.version_number;
    data['user'] = this.user;
    data['report_id'] = this.report_id;
    data['phone_upload_time'] = this.phone_upload_time;
    data['creation_time'] = this.creation_time;
    data['version_time'] = this.version_time;
    data['type'] = this.type;
    data['location_choice'] = this.location_choice;
    data['current_location_lon'] = this.current_location_lon;
    data['current_location_lat'] = this.current_location_lat;
    data['selected_location_lon'] = this.selected_location_lon;
    data['selected_location_lat'] = this.selected_location_lat;
    data['note'] = this.note;
    data['package_name'] = this.package_name;
    data['package_version'] = this.package_version;
    data['session'] = this.session;
    // data['photos'] = t
    if (this.responses != null) {
      data['responses'] = this.responses.map((r) => r.toJson()).toList();
    }
  }
}

class Photo {
  int id;
  String photo;
  String uuid;

  Photo({
    this.id,
    this.photo,
    this.uuid,
  });

  Photo.fromJson(Map<dynamic, dynamic> json) {
    print(json);
    id = json['id'];
    photo = json['photo'];
    uuid = json['uuid'];
  }
}
