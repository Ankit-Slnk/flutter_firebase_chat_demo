import 'package:chat/model/chatModel.dart';
import 'package:chat/utility/firebaseUtility.dart';
import 'package:chat/utility/locator.dart';

import 'base_model.dart';

class ChatViewModel extends BaseModel {
  final FirebaseUtility _firestoreService = locator<FirebaseUtility>();
  List<ChatModel> _chats;
  List<ChatModel> get chats => _chats;

  void listenToChats(String groupchatid, String myid) {
    setBusy(true);
    _firestoreService
        .listentoChatsRealtime(groupchatid, myid)
        .listen((chatsData) {
      List<ChatModel> updatedChats = chatsData;
      if (updatedChats != null && updatedChats.length > 0) {
        _chats = updatedChats;
        notifyListeners();
      }
      setBusy(false);
    });
  }

  void requestMoreData(String groupchatid, String myid) {
    _firestoreService.requestMoreData(groupchatid, myid);
  }
}
