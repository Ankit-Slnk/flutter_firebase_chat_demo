import 'dart:math';

import 'package:chat/utility/appColors.dart';
import 'package:chat/utility/appDimens.dart';
import 'package:chat/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserItemView extends StatefulWidget {
  QueryDocumentSnapshot doc;
  Function onTap;
  UserItemView({
    @required this.doc,
    @required this.onTap,
  });
  @override
  _UserItemViewState createState() => _UserItemViewState();
}

class _UserItemViewState extends State<UserItemView> {
  MediaQueryData mediaQueryData;
  Size size;
  AppDimens appDimens;

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    size = mediaQueryData.size;
    appDimens = AppDimens(size);

    return ListTile(
      onTap: widget.onTap,
      leading: Container(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Utility.getRamdomColor(),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          widget.doc.data()["name"].toString().substring(0, 1),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
      title: Text(
        widget.doc.data()["name"],
        style: TextStyle(
          color: widget.onTap == null
              ? AppColors.whiteColor
              : AppColors.primaryColor,
          fontSize: appDimens.text18,
        ),
      ),
    );
  }
}
