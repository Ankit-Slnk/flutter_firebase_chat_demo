import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as Path;
import 'appColors.dart';
import 'appStrings.dart';

class Utility {
  setShowNotification(String val) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(AppStrings.PREF_SHOW_NOTIFICATION, val);
  }

  Future<List<String>> uploadImage(String dateTime, String foldername,
      List<File> mediaImageList, String userid) async {
    List<String> uploadUrls = [];
    // int i=0;
    await Future.wait(
        mediaImageList.map((File image) async {
          StorageReference reference = FirebaseStorage.instance.ref().child(
              foldername +
                  "/" +
                  DateTime.now().toString() +
                  "/" +
                  userid +
                  returnrandomstring() +
                  returnrandomstring() +
                  "." +
                  Path.extension(image.path));
          StorageUploadTask uploadTask =
              reference.putData(image.readAsBytesSync());
          StorageTaskSnapshot storageTaskSnapshot;

          StorageTaskSnapshot snapshot = await uploadTask.onComplete;
          if (snapshot.error == null) {
            storageTaskSnapshot = snapshot;
            final String downloadUrl =
                await storageTaskSnapshot.ref.getDownloadURL();
            uploadUrls.add(downloadUrl);

            print('Upload success');
          } else {
            print('Error from image repo ${snapshot.error.toString()}');
          }
        }),
        eagerError: true,
        cleanUp: (_) {
          print('eager cleaned up');
        });

    return uploadUrls;
  }

  String returnrandomstring() {
    int value = Random().nextInt(999999) + 100000;
    return value.toString();
  }

  static Widget progress(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      ),
    );
  }

  static showToast({String msg}) {
    Fluttertoast.showToast(msg: msg);
  }

  static Widget imageLoader(String url, String placeholder,
      {BoxFit fit = BoxFit.cover}) {
    return (url == "null" || url == null || url.trim() == "")
        ? Image.asset(placeholder)
        : CachedNetworkImage(
            imageUrl: url,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: fit,
                ),
              ),
            ),
            placeholder: (context, url) => progress(context),
            errorWidget: (context, url, error) => Image.asset(placeholder),
          );
  }
}
