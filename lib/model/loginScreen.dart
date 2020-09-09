import 'package:chat/utility/appColors.dart';
import 'package:chat/utility/appDimens.dart';
import 'package:chat/utility/firebaseUtility.dart';
import 'package:chat/utility/utility.dart';
import 'package:chat/screens/chatUsersListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MediaQueryData mediaQueryData;
  Size size;
  AppDimens appDimens;
  TextEditingController nameController = TextEditingController();
  FocusNode namefn = FocusNode();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    size = mediaQueryData.size;
    appDimens = AppDimens(size);

    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(appDimens.paddingw16),
              constraints: BoxConstraints(
                  maxHeight: size.height - mediaQueryData.padding.top),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  FlutterLogo(
                    size: 150,
                  ),
                  Spacer(),
                  _textFormField(
                    index: 0,
                    text: "Name",
                    controller: nameController,
                    focusNode: namefn,
                    padding: EdgeInsets.only(
                      top: appDimens.paddingw2,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(
                    height: appDimens.paddingw16,
                  ),
                  Utility.loginButtonsWidget(
                    "",
                    "Continue",
                    () {
                      loginClick();
                    },
                    AppColors.blackBackGround,
                    AppColors.primaryColor,
                    appDimens,
                    AppColors.whiteColor,
                  ),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                ],
              ),
            ),
          ),
          isLoading ? Utility.progress(context) : Container()
        ],
      ),
    );
  }

  loginClick() {
    if (nameController.text.trim().length == 0) {
      Utility.showToast(msg: "Please enter name");
    } else {
      login();
    }
  }

  login() async {
    if (await Utility.checkInternet()) {
      if (mounted)
        setState(() {
          isLoading = true;
        });

      await FirebaseAuth.instance.signInAnonymously().then((value) {
        FirebaseUtility().setUser(
          value.user.uid,
          nameController.text.trim(),
        );
      });

      if (mounted)
        setState(() {
          isLoading = false;
        });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ChatUsersListScreen()),
      );
    } else {
      Utility.showToast(msg: "No Internet Connection");
    }
  }

  _textFormField(
      {@required int index,
      @required String text,
      int minlines,
      int maxlines,
      @required TextEditingController controller,
      @required FocusNode focusNode,
      TextInputType textInputType,
      TextInputAction textInputAction,
      EdgeInsetsGeometry padding,
      Widget icon,
      int maxlength,
      bool obscuretext}) {
    return Container(
      padding: padding != null
          ? padding
          : EdgeInsets.only(
              left: appDimens.paddingw16,
              right: appDimens.paddingw16,
              top: appDimens.paddingw16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType:
            textInputType != null ? textInputType : TextInputType.text,
        textInputAction:
            textInputAction != null ? textInputAction : TextInputAction.next,
        obscureText: obscuretext != null ? obscuretext : false,
        onFieldSubmitted: (value) {},
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: icon,
          counterText: "",
          contentPadding: const EdgeInsets.all(8.0),
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(5.0),
          //   borderSide: BorderSide(
          //     color: AppColors.primaryColor,
          //   ),
          // ),
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(5.0),
          //   borderSide: BorderSide(
          //     color: AppColors.primaryColor,
          //   ),
          // ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: AppColors.greyText, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: AppColors.greyText, width: 0.5),
          ),
          hintText: text,
        ),
        minLines: minlines,
        maxLines: maxlines,
        maxLength: maxlength != null ? maxlength : null,
      ),
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
