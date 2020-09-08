import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/model/chatModel.dart';
import 'package:chat/model/userResponse.dart';
import 'package:chat/utility/appAssets.dart';
import 'package:chat/utility/appColors.dart';
import 'package:chat/utility/appDimens.dart';
import 'package:chat/utility/appStrings.dart';
import 'package:chat/utility/firebaseUtility.dart';
import 'package:chat/utility/utility.dart';
import 'package:chat/viewModels/chatViewModel.dart';
import 'package:chat/widgets/imageSelectionPopUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider_architecture/_viewmodel_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fullPhoto.dart';

Color usercolor;
SharedPreferences utils;
final Radius radius = Radius.elliptical(10, 15);

class ChatWithAnotherUserPaginated extends StatefulWidget {
  String otherId;
  String userprovidername;
  ChatWithAnotherUserPaginated({
    Key key,
    @required this.otherId,
    @required this.userprovidername,
    // @required this.userprovideravatar,
  }) : super(key: key);

  @override
  _ChatWithAnotherUserPaginatedState createState() =>
      _ChatWithAnotherUserPaginatedState(
        otherId: otherId,
        userprovidername: userprovidername,
        // userprovideravatar: userprovideravatar,
      );
}

class _ChatWithAnotherUserPaginatedState
    extends State<ChatWithAnotherUserPaginated> {
  String myId, otherId, userprovideravatar = "", userprovidername;
  String url = "";
  AppDimens appDimens;
  _ChatWithAnotherUserPaginatedState({
    Key key,
    @required this.otherId,
    @required this.userprovidername,
    // @required this.userprovideravatar,
  });

  @override
  void initState() {
    super.initState();
    // BackButtonInterceptor.add(myInterceptor);
    // initpref();
    Utility().setShowNotification(AppStrings.HIDE);
    FirebaseUtility().clearallobjects();
    // FirebaseUtility.lastChatDocument = null;
    // FirebaseUtility.chatsController.close();
    // FirebaseUtility.chatsController = StreamController<List<ChatModel>>.broadcast();
  }

  @override
  void dispose() {
    // BackButtonInterceptor.remove(myInterceptor);
    // setPref("0");
    Utility().setShowNotification(AppStrings.SHOW);
    FirebaseUtility().clearallobjects();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    Navigator.pop(context, {"reload": "true"});
    return true;
  }

  // initpref() async {
  //   utils = await SharedPreferences.getInstance();
  //   if (utils != null) {
  //     usertype = utils.getString(AppConstants.PREF_USER_TYPE);
  //     if (mounted)
  //       setState(() {
  //         usercolor = AppColors.purple;
  //         url = utils.getString(AppConstants.saveUrlPrefName) +
  //             AppConstants.imageBaseUrl;
  //       });
  //   }
  // }

  // setPref(String id) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   sharedPreferences.setString(AppConstants.PREF_OTHER_ID, id);
  // }

  @override
  Widget build(BuildContext context) {
    appDimens = new AppDimens(MediaQuery.of(context).size);
    String name = userprovidername;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            // appBar: AppBar(
            //   backgroundColor: AppColors.whiteColor,
            //   automaticallyImplyLeading: false,
            //   iconTheme:
            //       IconThemeData(color: Colors.white, size: appDimens.text20),
            //   title: Row(
            //     children: <Widget>[
            //       IconButton(
            //         icon: Icon(Platform.isAndroid
            //             ? Icons.arrow_back
            //             : Icons.arrow_back_ios),
            //         onPressed: () {
            //           Navigator.pop(context, {"reload": "true"});
            //           // Navigator.pop(context);
            //         },
            //       ),
            //       SizedBox(
            //         width: MediaQuery.of(context).size.width * 0.02,
            //       ),
            //       SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            //       Text(
            //         name,
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: appDimens.text20,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              automaticallyImplyLeading: false,
              iconTheme:
                  IconThemeData(color: Colors.white, size: appDimens.text20),
              title: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Platform.isAndroid
                        ? Icons.arrow_back
                        : Icons.arrow_back_ios),
                    color: AppColors.primaryColor,
                    onPressed: () {
                      Navigator.pop(context, {"reload": "true"});
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Text(
                    "Chat",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: appDimens.text20,
                    ),
                  ),
                ],
              ),
            ),
            body: ChatScreen(
              otherId: otherId,
              // avatar: avtar,
              name: name,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String otherId;
  final String name;
  // final String avatar;

  ChatScreen({
    Key key,
    @required this.otherId,
    @required this.name,
    // @required this.avatar,
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
      otherId: otherId,
      //  avatar: avatar,
      name: name);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({
    Key key,
    @required this.otherId,
    @required this.name,
    // @required this.avatar,
  });

  String myId;
  String avatar;
  String otherId;
  String name;
  List<ChatModel> listMessage;
  String groupChatId;
  File imageFile;
  bool isLoading = false;
  String imageUrl;
  AuthResult user;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();
  SharedPreferences prefs;
  final themeColor = Color(0xff283891);
  final primaryColor = Color(0xff283891);
  final greyColor = Color(0xffaeaeae);
  final greyColor2 = Color(0xffE8E8E8);
  AppDimens appDimens;
  String usera_id;
  String userb_id;
  UserResponse loggedInUserResponse;

  // final greyColor = Colors.white;
  // final greyColor2 = Colors.white;

  @override
  void initState() {
    super.initState();
    _setPref();
    focusNode.addListener(onFocusChange);
    isLoading = false;
    // isShowSticker = false;
    imageUrl = '';
  }

  _setPref() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      if (prefs.getString(AppStrings.ACCESSTOKEN_USER_PREF_KEY) != null) {
        loggedInUserResponse = UserResponse.fromJson(
            jsonDecode(prefs.getString(AppStrings.ACCESSTOKEN_USER_PREF_KEY)));
      }
      print("here aaa");
      if (prefs != null) {
        if (mounted)
          setState(() {
            loggedInUserResponse;
            myId = loggedInUserResponse.userdata.id.toString();
          });
        readLocal();
        try {
          if (user != null) {
            user = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: loggedInUserResponse.userdata.email,
                password: loggedInUserResponse.userdata.email);
          }
        } catch (e) {}
      }
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // if (mounted)
      //   setState(() {
      //     isShowSticker = false;
      //   });
    }
  }

  readLocal() async {
    if (otherId.hashCode <= myId.hashCode) {
      groupChatId = '$myId-$otherId';
      usera_id = myId;
      userb_id = otherId;
    } else {
      groupChatId = '$otherId-$myId';
      usera_id = otherId;
      userb_id = myId;
    }
    print("id here aaaaa" + groupChatId);
    final QuerySnapshot result = await Firestore.instance
        .collection('user_chats_data')
        .where('id', isEqualTo: myId)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      Firestore.instance
          .collection('user_chats_data')
          .document(myId)
          .setData({'id': myId, 'chattingWith': otherId});
    } else {
      // _incrementcount(0);
      Firestore.instance
          .collection('user_chats_data')
          .document(myId)
          .updateData({'chattingWith': otherId});
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future getImage(ImageSource imageSource) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    ImagePicker().getImage(source: imageSource, imageQuality: 30).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        if (imageFile != null) {
          isLoading = true;
          if (mounted) setState(() {});
          uploadFile();
        }
      }
    });
  }

  Future uploadFile() async {
    List<File> images = List();
    images.clear();
    images.add(imageFile);
    await Utility()
        .uploadImage("", "users_chats", images, myId)
        .then((downloadurl) {
      if (mounted)
        setState(() {
          isLoading = false;
          onSendMessage(downloadurl[0], 1);
        });
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      if (type == 0) {
        textEditingController.clear();
      }
      FirebaseUtility().enterDatainUsersChatListCollection(
          type == 0 ? content : "",
          type,
          usera_id,
          userb_id,
          groupChatId,
          myId);
      Firestore.instance
          .collection('user_chats_data')
          .document(myId)
          .setData({'id': myId, 'chattingWith': otherId});

      Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .add({
        'idFrom': myId,
        'idTo': otherId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type
      });

      // _incrementcount(1);

      sendNotification(type, content);

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Utility.showToast(msg: "nothing to send");
    }
  }

  sendNotification(int type, String content) {
    // add notification in notification collection in firease
  }

  Widget buildItem(int index, ChatModel document) {
    if (document.idFrom == myId) {
      if (document.type == 0) {
        return InkWell(
          onTap: () {
            // otherChatOnTap(document);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              document.content,
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: appDimens.text12,
                                  fontStyle: FontStyle.normal),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Spacer(),
                              Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document.timestamp))),
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: appDimens.text10,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          )
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black26),
                        ],
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      } else if (document.type == 3) {
        return Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  Row(children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "You have Deleted this Message",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: appDimens.text12,
                                    fontStyle: FontStyle.normal),
                              )),
                          Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document.timestamp))),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: appDimens.text10,
                                    fontStyle: FontStyle.italic),
                              )),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: appDimens.chatWidth,
                      decoration: BoxDecoration(
                        color: AppColors.blackBackGround,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                      // margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                    ),
                  ])
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      } else {
        return Container(
          alignment: Alignment.centerRight,
          child: FlatButton(
            child: Material(
              child: Container(
                height: 200,
                width: 200,
                child:
                    Utility.imageLoader(document.content, AppAssets.logoAsset),
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullPhoto(
                    url: document.content,
                  ),
                ),
              );
            },
            onLongPress: () {
              // return showDialog<void>(
              //   context: context,
              //   barrierDismissible: true,
              //   builder: (
              //     BuildContext context,
              //   ) {
              //     return CustomPopup(
              //         title: "Delete Image",
              //         content:
              //             "Are you Sure You want to delete this image for everyone",
              //         onYesTap: () {
              //           Navigator.of(context).pop();
              //           Firestore.instance
              //               .collection('messages')
              //               .document(groupChatId)
              //               .collection(groupChatId)
              //               .document(document.documentid)
              //               .updateData(<String, dynamic>{"type": 3});
              //         },
              //         noString: "No",
              //         yesString: "Yes",
              //         onNoTap: () {
              //           Navigator.of(context).pop();
              //         });
              //   },
              // );
            },
            padding: EdgeInsets.all(0),
          ),
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      if (document.type == 0) {
        return InkWell(
          onTap: () {
            // otherChatOnTap(document);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              document.content,
                              style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: appDimens.text12,
                                  fontStyle: FontStyle.normal),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document.timestamp))),
                                style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: appDimens.text10,
                                    fontStyle: FontStyle.italic),
                              ),
                              Spacer(),
                            ],
                          )
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black26),
                        ],
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      } else if (document.type == 3) {
        return Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "This Message was Deleted",
                            style: TextStyle(
                                color: AppColors.blackBackGround,
                                fontSize: appDimens.text12,
                                fontStyle: FontStyle.normal),
                          )),
                      Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateFormat('dd MMM kk:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(document.timestamp))),
                            style: TextStyle(
                                color: AppColors.blackBackGround,
                                fontSize: appDimens.text10,
                                fontStyle: FontStyle.italic),
                          )),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: appDimens.chatWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5),
                      topLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      } else {
        return Container(
          alignment: Alignment.centerLeft,
          child: FlatButton(
            child: Material(
              child: Container(
                height: 200,
                width: 200,
                child:
                    Utility.imageLoader(document.content, AppAssets.logoAsset),
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullPhoto(url: document.content)));
            },
            padding: EdgeInsets.all(0),
          ),
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(context, {"reload": "true"});
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    appDimens = new AppDimens(MediaQuery.of(context).size);
    if (groupChatId != null &&
        myId != null &&
        groupChatId != "" &&
        myId != "") {
      return ViewModelProvider<ChatViewModel>.withConsumer(
        onModelReady: (model) => model.listenToChats(groupChatId, myId),
        // viewModel: ChatViewModel(),
        builder: (context, model, child) => WillPopScope(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    // List of messages
                    buildListMessage(model),
                    // Input content
                    buildInput(),
                  ],
                ),
                // Loading
                buildLoading()
              ],
            ),
          ),
          onWillPop: onBackPress,
        ),
        viewModelBuilder: () => ChatViewModel(),
      );
    } else {
      return Utility.progress(context);
    }
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? Utility.progress(context) : Container(),
    );
  }

  // Widget buildInput() {
  //   return Align(
  //     child: BottomAppBar(
  //       elevation: 0,
  //       color: Colors.grey[200],
  //       child: Container(
  //         padding: EdgeInsets.only(left: 8, bottom: 8, right: 8),
  //         width: MediaQuery.of(context).size.width,
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: <Widget>[
  //             Expanded(
  //               flex: 5,
  //               child: Padding(
  //                 padding: const EdgeInsets.only(right: 8.0),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(50)),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: <Widget>[
  //                       Expanded(
  //                         flex: 7,
  //                         child: Padding(
  //                           padding: const EdgeInsets.only(left: 10),
  //                           child: TextField(
  //                             scrollPadding: const EdgeInsets.all(2),
  //                             minLines: 1,
  //                             maxLines: 7,
  //                             textCapitalization: TextCapitalization.sentences,
  //                             controller: textEditingController,
  //                             style: TextStyle(fontSize: appDimens.text14),
  //                             decoration: InputDecoration(
  //                               hintText: "type a message",
  //                               contentPadding:
  //                                   EdgeInsets.all(appDimens.paddingw10),
  //                               hintStyle: TextStyle(
  //                                   color: AppColors.greyText,
  //                                   fontSize: appDimens.text14),
  //                               border: UnderlineInputBorder(
  //                                 borderSide:
  //                                     BorderSide(color: Colors.transparent),
  //                                 borderRadius: BorderRadius.circular(0),
  //                               ),
  //                               enabledBorder: UnderlineInputBorder(
  //                                 borderSide:
  //                                     BorderSide(color: Colors.transparent),
  //                                 borderRadius: BorderRadius.circular(0),
  //                               ),
  //                               focusedBorder: UnderlineInputBorder(
  //                                 borderSide:
  //                                     BorderSide(color: Colors.transparent),
  //                                 borderRadius: BorderRadius.circular(0),
  //                               ),
  //                             ),
  //                             focusNode: focusNode,
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         flex: 0,
  //                         child: Container(
  //                           width: 50,
  //                           child: MaterialButton(
  //                             padding: EdgeInsets.symmetric(
  //                                 vertical: appDimens.paddingw10),
  //                             child: Icon(
  //                               Icons.add,
  //                               color: Colors.grey,
  //                               size: 30,
  //                             ),
  //                             onPressed: () {
  //                               _selectImagePopup("1");
  //                             },
  //                           ),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 0,
  //               child: Container(
  //                 padding: EdgeInsets.all(0),
  //                 width: 50,
  //                 height: 50,
  //                 decoration: BoxDecoration(
  //                   color: Colors.green,
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: IconButton(
  //                   alignment: Alignment.center,
  //                   icon: Icon(
  //                     Icons.send,
  //                     color: Colors.white,
  //                     size: 25,
  //                   ),
  //                   onPressed: () {
  //                     onSendMessage(textEditingController.text, 0);
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildInput() {
    return Align(
      child: BottomAppBar(
        elevation: 0,
        color: AppColors.appbackgroundcolor,
        child: Container(
          padding: EdgeInsets.only(left: 8, bottom: 8, right: 8),
          width: MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: AppColors.greyText, width: 0.5),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              scrollPadding: const EdgeInsets.all(2),
                              minLines: 1,
                              maxLines: 7,
                              textCapitalization: TextCapitalization.sentences,
                              controller: textEditingController,
                              style: TextStyle(
                                  fontSize: appDimens.text14,
                                  color: AppColors.greyText),
                              decoration: InputDecoration(
                                hintText: "Type a message",
                                contentPadding:
                                    EdgeInsets.all(appDimens.paddingw10),
                                hintStyle: TextStyle(
                                    color: AppColors.greyText,
                                    fontSize: appDimens.text14),
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              focusNode: focusNode,
                            ),
                          ),
                        ),
                        Container(
                            child: IconButton(
                                splashColor: Colors.transparent,
                                onPressed: () {
                                  _selectImagePopup("1");
                                },
                                icon: Icon(
                                  Icons.attach_file,
                                  color: Colors.grey,
                                )))
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    alignment: Alignment.center,
                    splashColor: Colors.transparent,
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      onSendMessage(textEditingController.text, 0);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectImagePopup(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageSelectionPopUp(
          onCameraTap: () {
            Navigator.pop(context);
            getImage(ImageSource.camera);
            // _onImageButtonPressed(ImageSource.camera, type);
          },
          onGalleryTap: () {
            Navigator.pop(context);
            getImage(ImageSource.gallery);
            // _onImageButtonPressed(ImageSource.gallery, type);
          },
          onCloseTap: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget buildListMessage(ChatViewModel model) {
    return Flexible(
        child: groupChatId == ''
            ? Center(child: isLoading ? Utility.progress(context) : Container())
            : model.chats == null
                ? Container(
                    color: Colors.grey[200],
                    // child: Center(
                    //   child: Text("No chats found"),
                    // ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(10.0),
                      // itemBuilder: (context, index) => buildItem(
                      //     index, snapshot.data.documents[index]),
                      itemBuilder: (context, index) {
                        if (index % 20 == 0) {
                          model.requestMoreData(groupChatId, myId);
                        }
                        // return CreationAwareListItem(
                        //   itemCreated: () {
                        //     print("here aaa bbb " + index.toString());
                        //     if (index % 20 == 0) {
                        //       // model.requestMoreData(groupChatId, myId);
                        //     }
                        //   },
                        //   child: buildItem(index, model.chats[index]),
                        // );
                        return buildItem(index, model.chats[index]);
                        // return CreationAwareListItem(
                        //   itemCreated: () {
                        //     print("here aaa bbb " + index.toString());
                        //     if (index % 20 == 0) {
                        //       // model.requestMoreData(groupChatId, myId);
                        //     }
                        //   },
                        //   child:
                        // );
                      },
                      itemCount: model.chats.length,
                      reverse: true,
                      controller: listScrollController,
                    ),
                  ));
  }
}
