import 'dart:async';

import 'package:chat/model/chatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FirebaseUtility {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamController<List<ChatModel>> _chatsController =
      StreamController<List<ChatModel>>.broadcast();

  //collections name
  static String CHAT_MESSAGES_COLLECTION = "messages";
  static String CHAT_USERS_COLLECTION = "chat_users";
  static String CHAT_USERS_LIST = "users_chat_list";
  static String USER_CHAT_DATA = "user_chats_data";

  static int documentLimit = 10;

  // Paged Structure
  static List<List<ChatModel>> allPagedResults = List<List<ChatModel>>();
  static DocumentSnapshot lastChatDocument;
  static bool hasMoreChats = true;
  static final StreamController<List<ChatModel>> chatsController =
      StreamController<List<ChatModel>>.broadcast();
  final CollectionReference userschatlistsCollection =
      FirebaseFirestore.instance.collection(CHAT_USERS_LIST);
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection(CHAT_USERS_COLLECTION);
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection(CHAT_MESSAGES_COLLECTION);
  final CollectionReference userChatCollection =
      FirebaseFirestore.instance.collection(USER_CHAT_DATA);

  clearallobjects() {
    lastChatDocument = null;
    hasMoreChats = true;
    allPagedResults.clear();
  }

  FirebaseAuth getFirebaseAuth() {
    return _auth;
  }

  //add user
  Future<void> setUser(String id, String name) async {
    await userCollection.doc(id).set({
      "id": id,
      "name": name,
    });
  }

  //get all users
  Stream<QuerySnapshot> getUsersList() {
    return userCollection.snapshots();
  }

  Stream listentoChatsRealtime(String groupChatId, String myId) {
    _requestChatMessages(groupChatId, myId);
    return chatsController.stream;
  }

  setMessages(String groupChatId, String myId, String otherId, String timestamp,
      String content, int type) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .add({
      'idFrom': myId,
      'idTo': otherId,
      'timestamp': timestamp,
      'content': content,
      'type': type
    });
  }

  void _requestChatMessages(String groupChatId, String myId) {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    var pageChatsQuery = messagesCollection
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20);
    if (lastChatDocument != null) {
      pageChatsQuery = pageChatsQuery.startAfterDocument(lastChatDocument);
    }
    if (!hasMoreChats) return;
    var currentRequestIndex = allPagedResults.length;
    try {
      pageChatsQuery.snapshots().listen((chatsSnapshot) {
        if (chatsSnapshot.docs.isNotEmpty) {
          var chats = chatsSnapshot.docs
              .map(
                  (snapshot) => ChatModel.fromMap(snapshot.data(), snapshot.id))
              .where((mappedItem) => mappedItem.timestamp != null)
              .toList();
          var pageExists = currentRequestIndex < allPagedResults.length;
          if (pageExists) {
            allPagedResults[currentRequestIndex] = chats;
          }
          // if page does'nt exist add the page data
          else {
            allPagedResults.add(chats);
          }

          var allChats = allPagedResults.fold<List<ChatModel>>(
              List<ChatModel>(),
              (initialValue, pageItems) => initialValue..addAll(pageItems));
          // Add the chats onto the controller
          chatsController.add(allChats);

          // Save the last document from the results. ONLY if it's the current last page
          if (currentRequestIndex == allPagedResults.length - 1) {
            lastChatDocument = chatsSnapshot.docs.last;
          }

          //Determining if there is more chats in the request
          hasMoreChats = chats.length == 20;
        }
      });
    } catch (e) {
      debugPrint("EXCEPTION " + e.toString());
    }
  }

  void requestMoreData(String groupchatid, String myid) =>
      _requestChatMessages(groupchatid, myid);

  Stream<QuerySnapshot> getChatMessages(String groupChatId, String myId) {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return messagesCollection
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getFirstChatMessages(String groupChatId, String myId) {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return messagesCollection
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  Stream<QuerySnapshot> getNextChatMessages2(
      List<DocumentSnapshot> documentList, String groupChatId, String myId) {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return messagesCollection
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .startAfter([documentList[documentList.length - 1].id])
        .limit(20)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> getNextChatMessages(
      List<DocumentSnapshot> documentList,
      String groupChatId,
      String myId) async {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return (await FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .startAfter([documentList[documentList.length - 1].id])
            .limit(20)
            .get())
        .docs;
  }

  Future<void> enterDatainUsersChatListCollection(String message, int chattype,
      String usera_id, String userb_id, String groupchatid, String myid) async {
    List<String> idsarray = List();
    idsarray.clear();
    idsarray.add(usera_id);
    idsarray.add(userb_id);
    QuerySnapshot qs = await userschatlistsCollection
        .where('groupchatid', isEqualTo: groupchatid)
        .get();
    if (qs.docs.length > 0) {
      userschatlistsCollection.doc(qs.docs[0].id).update({
        "type": chattype,
        "message": message,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "usera_badge": FieldValue.increment(
          (myid == userb_id ? (1) : (0)),
        ),
        "userb_badge": FieldValue.increment(
          (myid == usera_id ? (1) : (0)),
        ),
      });
    } else {
      userschatlistsCollection.doc().set({
        "usera_id": usera_id,
        "userb_id": userb_id,
        "type": chattype,
        "groupchatid": groupchatid,
        "idsarray": idsarray,
        "message": message,
        "usera_badge": myid == userb_id ? 1 : 0,
        "userb_badge": myid == usera_id ? 1 : 0,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      });
    }
  }

  Stream<QuerySnapshot> getUsersChatList(String user_id) {
    return userschatlistsCollection
        .where('idsarray', arrayContains: user_id)
        .snapshots();
  }

  Stream<QuerySnapshot> getUsersChatListIndividualBadgeValue(
      String myId, String otherId) {
    String groupChatId = "";
    if (otherId.hashCode <= myId.hashCode) {
      groupChatId = '$myId-$otherId';
    } else {
      groupChatId = '$otherId-$myId';
    }
    return userschatlistsCollection
        .where('groupchatid', isEqualTo: groupChatId)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> fetchFirstUsersChatList(String user_id) async {
    return (await userschatlistsCollection
            .where('idsarray', arrayContains: user_id)
            .orderBy('timestamp', descending: true)
            .limit(documentLimit)
            .get())
        .docs;
  }

  Future<List<DocumentSnapshot>> fetchNextUsersChatList(
      List<DocumentSnapshot> documentList, String user_id) async {
    return (await userschatlistsCollection
            .where('idsarray', arrayContains: user_id)
            .orderBy('timestamp', descending: true)
            .startAfter([documentList[documentList.length - 1].id])
            .limit(documentLimit)
            .get())
        .docs;
  }

  Future<void> messagesreadupdatebadgevaluetozero(
      String groupChatId, String myid) async {
    QuerySnapshot qs = await userschatlistsCollection
        .where('groupchatid', isEqualTo: groupChatId)
        .get();
    if (qs.docs.length > 0) {
      if (qs.docs[0].data()['usera_id'] == myid) {
        userschatlistsCollection.doc(qs.docs[0].id).update({"usera_badge": 0});
      } else {
        userschatlistsCollection.doc(qs.docs[0].id).update({"userb_badge": 0});
      }
    }
  }

  Future<QuerySnapshot> getUserChatData(String myId) async {
    return await FirebaseFirestore.instance
        .collection('user_chats_data')
        .where('id', isEqualTo: myId)
        .get();
  }

  setUserChatData(String myId, String otherId) async {
    await FirebaseFirestore.instance
        .collection('user_chats_data')
        .doc(myId)
        .set({'id': myId, 'chattingWith': otherId});
  }

  updateUserChatData(String myId, String otherId) async {
    await FirebaseFirestore.instance
        .collection('user_chats_data')
        .doc(myId)
        .update({'chattingWith': otherId});
  }
}
