import 'package:chat/utility/appColors.dart';
import 'package:chat/utility/appDimens.dart';
import 'package:chat/utility/firebaseUtility.dart';
import 'package:chat/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatUsersListScreen extends StatefulWidget {
  @override
  _ChatUsersListScreenState createState() => _ChatUsersListScreenState();
}

class _ChatUsersListScreenState extends State<ChatUsersListScreen> {
  MediaQueryData mediaQueryData;
  Size size;
  AppDimens appDimens;

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    size = mediaQueryData.size;
    appDimens = AppDimens(size);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(
            fontSize: appDimens.text20,
          ),
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseUtility().getUsersList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data != null) {
          return snapshot.data.docs.length == 0
              ? Utility.getEmptyView(appDimens.text14)
              : Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return usersItemView(snapshot.data.docs[index]);
                    },
                  ),
                );
        } else {
          return Utility.progress(context);
        }
      },
    );
  }

  Widget usersItemView(QueryDocumentSnapshot doc) {
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          doc.data()["name"].toString().substring(0, 1),
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
      title: Text(
        doc.data()["name"],
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: appDimens.text18,
        ),
      ),
    );
  }
}
