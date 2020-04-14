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
  String session;
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
    this.responses,
  });

  Report.fromJson(Map<String, dynamic> json) {
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

    if (json['responses'] != null) {
      responses = new List<Question>();
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
    if (this.responses != null) {
      data['responses'] = this.responses.map((r) => r.toJson()).toList();
    }
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    if (responses != null) {
      data['responses'] = responses.map((r) => r.toJson()).toList();
    }
    return data;
  }
}
