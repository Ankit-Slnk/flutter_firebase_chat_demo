import 'package:chat/screens/loginScreen.dart';
import 'package:chat/screens/chatUsersListScreen.dart';
import 'package:chat/utility/appStrings.dart';
import 'package:chat/utility/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: pref == null
            ? Container(
                color: Colors.white,
              )
            : getNextScreen(),
      ),
    );
  }

  Widget getNextScreen() {
    if (pref.get(AppStrings.CHAT_APP_PREFERENCE) == null) {
      return LoginScreen();
    } else {
      return ChatUsersListScreen();
    }
  }
}
