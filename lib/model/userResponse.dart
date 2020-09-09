class UserResponse {
  Userdata userdata;

  UserResponse({
    this.userdata,
  });

  UserResponse.fromJson(Map<String, dynamic> json) {
    userdata = json['userdata'] != null
        ? new Userdata.fromJson(json['userdata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userdata != null) {
      data['userdata'] = this.userdata.toJson();
    }
    return data;
  }
}

class Userdata {
  int id;
  String name;

  Userdata({
    this.id,
    this.name,
  });

  Userdata.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
