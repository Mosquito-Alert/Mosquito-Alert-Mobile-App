class Report {
  String id;
  double lat;
  double long;
  DateTime creationTime;

  Report({
    this.id,
    this.lat,
    this.long,
    this.creationTime,
  });

  Report.fromJson(Map<String, dynamic> json){
    id = json['id'];
    lat = json['lat'];
    long = json['long'];
    creationTime = json['creationTime'];
  }

Map<String, dynamic> toJson(){
  final Map<String,dynamic> data = new Map<String,dynamic>(); 
  data['id'] = this.id; 
  data['lat'] = this.lat;
  data['long'] = this.long;
  data['creationTime'] = this.creationTime;
}

}
