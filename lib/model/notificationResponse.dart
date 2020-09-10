import 'package:chat/model/userData.dart';

class NotificationResponse {
  Notification notification;
  NotificationData data;

  NotificationResponse({this.notification, this.data});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    notification = json['notification'] != null
        ? new Notification.fromJson(json['notification'])
        : null;
    data = json['data'] != null
        ? new NotificationData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notification != null) {
      data['notification'] = this.notification.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Notification {
  String title;
  String body;

  Notification({this.title, this.body});

  Notification.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "";
    body = json['body'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}

class NotificationData {
  NotificationDetailData data;

  NotificationData({this.data});

  NotificationData.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? new NotificationDetailData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class NotificationDetailData {
  int notification_id;
  String title;
  String body;
  String clickAction;
  Userdata user_data;
  // String task_id;
  // String offer_id;

  // NotificationDetailData(
  //     {this.title, this.body, this.clickAction, this.user_data});
  NotificationDetailData(
      {this.title, this.body, this.clickAction, this.user_data});

  NotificationDetailData.fromJson(Map<String, dynamic> json) {
    notification_id = json['notification_id'] ?? 0;
    title = json['title'] ?? "";
    body = json['body'] ?? "";
    clickAction = json['click_action'] ?? "";
    // task_id = json['task_id'] != null ? json['task_id'].toString() : "" ?? "";
    // offer_id =
    //     json['offer_id'] != null ? json['offer_id'].toString() : "" ?? "";
    user_data = json['user_data'] != null
        ? new Userdata.fromJson(json['user_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title ?? "";
    data['body'] = this.body ?? "";
    // data['task_id'] = this.task_id ?? "";
    // data['offer_id'] = this.offer_id ?? "";
    data['click_action'] = this.clickAction ?? "";
    if (this.user_data != null) {
      data['user_data'] = this.user_data.toJson();
    }

    return data;
  }
}
