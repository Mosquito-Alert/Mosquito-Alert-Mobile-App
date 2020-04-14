class Session {
  int id;
  int session_ID;
  String user;
  String session_start_time;
  String session_end_time;

  Session({
    this.id,
    this.session_ID,
    this.user,
    this.session_start_time,
    this.session_end_time,
  });

  Session.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    session_ID = json['session_ID'];
    user = json['user'];
    session_start_time = json['session_start_time'];
    session_end_time = json['session_end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['session_ID'] = this.session_ID;
    data['user'] = this.user;
    data['session_start_time'] = this.session_start_time;
    data['session_end_time'] = this.session_end_time;
    return data;
  }
}
