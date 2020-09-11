import 'dart:math';

import 'package:chat/screens/loginScreen.dart';
import 'package:chat/screens/ChatwithAnotherUserPaginated.dart';
import 'package:chat/utility/appColors.dart';
import 'package:chat/utility/appDimens.dart';
import 'package:chat/utility/appStrings.dart';
import 'package:chat/utility/firebaseUtility.dart';
import 'package:chat/utility/utility.dart';
import 'package:chat/widgets/userItemView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatUsersListScreen extends StatefulWidget {
  @override
  _ChatUsersListScreenState createState() => _ChatUsersListScreenState();
}

class _ChatUsersListScreenState extends State<ChatUsersListScreen> {
  MediaQueryData mediaQueryData;
  Size size;
  AppDimens appDimens;
  SharedPreferences pref;

  @override
  void initState() {
    getPref();
    super.initState();
  }

  getPref() async {
    pref = await SharedPreferences.getInstance();
    if (mounted) setState(() {});
  }

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
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.signOutAlt),
            onPressed: () {
              logout();
            },
          )
        ],
      ),
      body: body(),
    );
  }

  logout() async {
    FirebaseAuth.instance.signOut();
    await pref.remove(AppStrings.CHAT_APP_PREFERENCE);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
      (Route<dynamic> route) => false,
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
    return UserItemView(
      doc: doc,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ChatWithAnotherUserPaginated(
              doc: doc,
            ),
          ),
        );
      },
    );
  }
}
