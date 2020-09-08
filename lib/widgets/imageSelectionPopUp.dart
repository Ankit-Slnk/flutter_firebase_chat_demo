import 'dart:io';

import 'package:chat/utility/appColors.dart';
import 'package:chat/utility/appDimens.dart';
import 'package:flutter/material.dart';

class ImageSelectionPopUp extends StatelessWidget {
  ImageSelectionPopUp({
    this.onCameraTap,
    this.onGalleryTap,
    this.onCloseTap,
  });

  final Function onCameraTap;
  final Function onGalleryTap;
  final Function onCloseTap;

  AppDimens appDimens;

  @override
  Widget build(BuildContext context) {
    appDimens = new AppDimens(MediaQuery.of(context).size);
    return AlertDialog(
      contentPadding: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
      ),
      title: Text(
        "Image source",
        style:
            TextStyle(color: AppColors.blackColor, fontSize: appDimens.text18),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: onCameraTap,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: AppColors.fbButtonColor,
                        ),
                        Text(
                          "Take Photo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: appDimens.text14),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: onGalleryTap,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.photo_library,
                          color: AppColors.fbButtonColor,
                          size: 50,
                        ),
                        Text(
                          "Choose Photo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: appDimens.text14),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: AppColors.fbButtonColor,
                  child: Text(
                    "Close",
                    style: TextStyle(
                        color: Colors.white, fontSize: appDimens.text16),
                  ),
                  onPressed: onCloseTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
