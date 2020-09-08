import 'dart:convert';
import 'dart:io';
import 'package:chat/FlushBar/CustomFlushBar.dart';
import 'package:chat/model/notificationResponse.dart';
import 'package:chat/screens/ChatwithAnotherUserPaginated.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appColors.dart';
import 'appStrings.dart';

class FirebaseMessagingService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  BuildContext context;
  SharedPreferences sharedPreferences;
  var _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
  var _lastOnResumeForFlushBar = DateTime.now().microsecondsSinceEpoch;

  FirebaseMessagingService(BuildContext context) {
    this.context = context;
  }

  getMessage() {
    if (Platform.isIOS) {
      firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {});
    }
    firebaseMessaging.getToken().then((token) {});
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        if ((DateTime.now().microsecondsSinceEpoch - _lastOnResumeCall) >
            1000000) {
          _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
          if (Platform.isIOS) {
            _onDidReceiveLocalNotification(false, message["data"]);
          } else if (Platform.isAndroid) {
            _onDidReceiveLocalNotification(false, message["data"]["data"]);
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        if ((DateTime.now().microsecondsSinceEpoch - _lastOnResumeCall) >
            1000000) {
          _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
          if (Platform.isIOS) {
            _onDidReceiveLocalNotification(true, message["data"]);
          } else if (Platform.isAndroid) {
            _onDidReceiveLocalNotification(true, message["data"]["data"]);
          }
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        if ((DateTime.now().microsecondsSinceEpoch - _lastOnResumeCall) >
            1000000) {
          _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
          if (Platform.isIOS) {
            _onDidReceiveLocalNotification(true, message["data"]);
          } else if (Platform.isAndroid) {
            _onDidReceiveLocalNotification(true, message["data"]["data"]);
          }
        }
      },
    );
  }

  Future _onDidReceiveLocalNotification(bool isResume, String data) async {
    NotificationDetailData notification =
        NotificationDetailData.fromJson(jsonDecode(data));
    sharedPreferences = await SharedPreferences.getInstance();
    if ((DateTime.now().microsecondsSinceEpoch - _lastOnResumeForFlushBar) >
        1000000) {
      // _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
      _lastOnResumeForFlushBar = DateTime.now().microsecondsSinceEpoch;
      try {
        if (sharedPreferences.getString(AppStrings.PREF_SHOW_NOTIFICATION) ==
            AppStrings.SHOW) {
          if (notification.clickAction == "NEW_CHAT" ||
              notification.clickAction == "ORDER_BUYER" ||
              notification.clickAction == "ORDER_SELLER") {
            if (notification.user_data != null) {
              shownotification(isResume, notification);
            }
          }
        }
      } catch (e) {
        print("notification error");
        print(e);
      }
    }
  }

  shownotification(bool isResume, NotificationDetailData notification) {
    // String type = sharedPreferences.getString(Constants.USERTYPE);
    // final notificationPageState =
    //     Provider.of<CommonResponse>(context, listen: false);

    if (isResume) {
      _onSelectNotification(notification);
    } else {
      Flushbar(
        animationDuration: Duration(milliseconds: 50),
        margin: EdgeInsets.all(12),
        borderRadius: 8,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.white,
        flushbarStyle: FlushbarStyle.FLOATING,
        boxShadows: [BoxShadow(blurRadius: 8, color: Colors.grey[400])],
        // icon: Container(
        // color: Colors.black,
        // color: AppColors.blackBackGround,
        // margin: EdgeInsets.only(left: 1),
        // height: 42,
        // width: 39,
        // padding: EdgeInsets.all(1),
        // child: ClipRRect(
        //     borderRadius: BorderRadius.circular(58),
        //     child: Utility.imageLoader(
        //         notification.user_data.profilePhoto,
        //         AppAssetsPath.placeholder)),
        // ),
        titleText: Text(
          notification.user_data.name.trim().length == 0 ||
                  notification.user_data.name == "" ||
                  notification.user_data.name == "null"
              ? notification.title
              : "New Message from " + notification.user_data.name + "zzzzzz",
          style: TextStyle(color: AppColors.blackBackGround, fontSize: 15),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        messageText: notification.body.toString() != "Image"
            ? Text(
                notification.body == "" || notification.body == "null"
                    ? notification.body
                    : notification.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: AppColors.blackBackGround, fontSize: 13),
              )
            : Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.image,
                      size: 20,
                      color: Colors.grey,
                    ),
                    Container(
                      child: Text(
                        "Image",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        duration: Duration(seconds: 5),
        onTap: ((flush) async {
          // if ((DateTime.now().microsecondsSinceEpoch - _lastOnResumeCall) >
          //     1000000) {
          //   _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
          // }
          _onSelectNotification(notification);
        }),
      ).show(context);
    }
  }

  Future _onSelectNotification(
    NotificationDetailData notificationData,
  ) async {
    if (notificationData != null) {
      if (notificationData.clickAction == "NEW_CHAT") {
        // print("otherId  otherId  otherId " +
        //     notificationData.user_data.toJson().toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatWithAnotherUserPaginated(
              otherId: notificationData.user_data.id.toString(),
              userprovidername: notificationData.user_data.name,
            ),
          ),
        );
      }
      //  else if (notificationData.clickAction == "ORDER_BUYER") {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ManagedOrdersDetail(
      //         orderDetail: null,
      //         documentId: notificationData.user_data.document_id,
      //       ),
      //     ),
      //   );
      // } else if (notificationData.clickAction == "ORDER_SELLER") {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => InBoundOrderDetails(
      //         orderDetail: null,
      //         documentId: notificationData.user_data.document_id,
      //       ),
      //     ),
      //   );
      // }
    }
  }
}
