import 'dart:async';

import 'package:chat/model/chatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FirebaseUtility {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamController<List<ChatModel>> _chatsController =
      StreamController<List<ChatModel>>.broadcast();
  //collections name";
  static String CHAT_MESSAGES_COLLECTION = "messages";
  static String CHAT_USERS_COLLECTION = "chat_users";
  static String CHAT_COUNT_COLLECTION = "chat_count";
  static String CHAT_USERS_LIST = "users_chat_list";

  static int documentLimit = 10;

  // Paged Structure
  static List<List<ChatModel>> allPagedResults = List<List<ChatModel>>();
  static DocumentSnapshot lastChatDocument;
  static bool hasMoreChats = true;
  static final StreamController<List<ChatModel>> chatsController =
      StreamController<List<ChatModel>>.broadcast();
  final CollectionReference userschatlistsCollection =
      Firestore.instance.collection(CHAT_USERS_LIST);

  clearallobjects() {
    lastChatDocument = null;
    hasMoreChats = true;
    allPagedResults.clear();
  }

  FirebaseAuth getFirebaseAuth() {
    return _auth;
  }

  final CollectionReference _chatsCollectionReference =
      Firestore.instance.collection(CHAT_MESSAGES_COLLECTION);

  //get documents and collections

  Stream listentoChatsRealtime(String groupChatId, String myId) {
    // Register the handler for when the posts data changes
    // print("################################################ 2 here 1  gp " +
    //     groupChatId.toString());
    // print(
    //     "################################################ 222222 here 1 myid " +
    //         myId.toString());
    _requestChatMessages(groupChatId, myId);
    return chatsController.stream;
  }

  void _requestChatMessages(String groupChatId, String myId) {
    // print("################################################ 1111");
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    var pageChatsQuery = Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20);
    // print("################################################ 2.1 " +
    // pageChatsQuery.toString());
    if (lastChatDocument != null) {
      // print("################################################ 2.2 ");
      pageChatsQuery = pageChatsQuery.startAfterDocument(lastChatDocument);
    }
    // print("################################################ 3");

    if (!hasMoreChats) return;
    var currentRequestIndex = allPagedResults.length;
    // print("################################################ 4 ");
    try {
      pageChatsQuery.snapshots().listen((chatsSnapshot) {
        // print("################################################ 5  " +
        // chatsSnapshot.documents.length.toString());

        if (chatsSnapshot.documents.isNotEmpty) {
          // print(chatsSnapshot.documentChanges.toString());
          // print("################################################ 5.1");
          var chats = chatsSnapshot.documents
              .map((snapshot) =>
                  ChatModel.fromMap(snapshot.data, snapshot.documentID))
              .where((mappedItem) => mappedItem.timestamp != null)
              .toList();
          var pageExists = currentRequestIndex < allPagedResults.length;
          // if page exists update the value to the new posts
          if (pageExists) {
            // print("################################################ 5.2");
            allPagedResults[currentRequestIndex] = chats;
          }
          // if page does'nt exist add the page data
          else {
            // print("################################################ 5.3");
            allPagedResults.add(chats);
          }

          var allChats = allPagedResults.fold<List<ChatModel>>(
              List<ChatModel>(),
              (initialValue, pageItems) => initialValue..addAll(pageItems));
          // Add the chats onto the controller
          chatsController.add(allChats);
          // print("################################################ 5.4");

          // Save the last document from the results. ONLY if it's the current last page
          if (currentRequestIndex == allPagedResults.length - 1) {
            lastChatDocument = chatsSnapshot.documents.last;
          }
          // print("################################################ 6");

          //Determining if there is more chats in the request
          hasMoreChats = chats.length == 20;
        }
      });
    } catch (e) {
      debugPrint(
          "####################################################### EXCEPTION " +
              e.toString());
    }
  }

  void requestMoreData(String groupchatid, String myid) =>
      _requestChatMessages(groupchatid, myid);

  Stream<QuerySnapshot> getChatMessages(String groupChatId, String myId) {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        // .limit(20)
        .snapshots();
  }

  Stream<QuerySnapshot> getFirstChatMessages(String groupChatId, String myId) {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  Stream<QuerySnapshot> getNextChatMessages2(
      List<DocumentSnapshot> documentList, String groupChatId, String myId) {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .startAfter([documentList[documentList.length - 1].documentID])
        .limit(20)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> getNextChatMessages(
      List<DocumentSnapshot> documentList,
      String groupChatId,
      String myId) async {
    messagesreadupdatebadgevaluetozero(groupChatId, myId);
    return (await Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .startAfter([documentList[documentList.length - 1].documentID])
            .limit(20)
            .getDocuments())
        .documents;
  }

  Future<void> enterDatainUsersChatListCollection(String message, int chattype,
      String usera_id, String userb_id, String groupchatid, String myid) async {
    List<String> idsarray = List();
    idsarray.clear();
    idsarray.add(usera_id);
    idsarray.add(userb_id);
    QuerySnapshot qs = await userschatlistsCollection
        .where('groupchatid', isEqualTo: groupchatid)
        .getDocuments();
    if (qs.documents.length > 0) {
      userschatlistsCollection.document(qs.documents[0].documentID).updateData({
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
      userschatlistsCollection.document().setData({
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
    print("groupchatid " + groupChatId);
    return userschatlistsCollection
        .where('groupchatid', isEqualTo: groupChatId)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> fetchFirstUsersChatList(String user_id) async {
    return (await userschatlistsCollection
            .where('idsarray', arrayContains: user_id)
            .orderBy('timestamp', descending: true)
            .limit(documentLimit)
            .getDocuments())
        .documents;
  }

  Future<List<DocumentSnapshot>> fetchNextUsersChatList(
      List<DocumentSnapshot> documentList, String user_id) async {
    return (await userschatlistsCollection
            .where('idsarray', arrayContains: user_id)
            .orderBy('timestamp', descending: true)
            .startAfter([documentList[documentList.length - 1].documentID])
            .limit(documentLimit)
            .getDocuments())
        .documents;
  }

  Future<void> messagesreadupdatebadgevaluetozero(
      String groupChatId, String myid) async {
    QuerySnapshot qs = await userschatlistsCollection
        .where('groupchatid', isEqualTo: groupChatId)
        .getDocuments();
    if (qs.documents.length > 0) {
      if (qs.documents[0]['usera_id'] == myid) {
        userschatlistsCollection
            .document(qs.documents[0].documentID)
            .updateData({"usera_badge": 0});
      } else {
        userschatlistsCollection
            .document(qs.documents[0].documentID)
            .updateData({"userb_badge": 0});
      }
    }
  }
}
