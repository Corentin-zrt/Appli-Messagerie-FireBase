import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discord_my_version/models/message_model.dart';
import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/models/user_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  //! The Datas :

  // Collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection("users");

  Future updateUserData(
      String username, String description, String statut, String uid) async {
    await usersCollection.document(uid).setData({
      "username": username,
      "description": description,
      "statut": statut,
      "uid": uid,
    });
  }

  Future updateUserDataFriend(UserModel userMe) async {
    QuerySnapshot resultFriends;
    await Firestore.instance
        .collection("users/${userMe.uid}/all_friends")
        .getDocuments()
        .then((snapshot) {
      resultFriends = snapshot;
    });

    QuerySnapshot resultFriendRequests;
    await Firestore.instance
        .collection("users/${userMe.uid}/all_friends")
        .getDocuments()
        .then((snapshot) {
      resultFriendRequests = snapshot;
    });

    resultFriends.documents.forEach((element) async {
      String uid1 = element.data["uid"];

      await Firestore.instance.collection("users/${uid1}/all_friends").document(userMe.uid).setData({
        "username": userMe.username,
        "description": userMe.description,
        "statut": userMe.statut,
        "uid": userMe.uid,
      });
    });

    resultFriendRequests.documents.forEach((element) async {
      String uid2 = element.data["uid"];

      await Firestore.instance.collection("users/${uid2}/all_friends").document(userMe.uid).setData({
        "username": userMe.username,
        "description": userMe.description,
        "statut": userMe.statut,
        "uid": userMe.uid,
      });
    });
  }

  // users list from snapshot
  List<UserModel> _usersListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return UserModel(
        username: doc.data["username"] ?? "",
        description: doc.data["description"] ?? "",
        statut: doc.data["statut"] ?? "",
        uid: doc.data["uid"] ?? "",
      );
    }).toList();
  }

  // userData from Snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      username: snapshot.data["username"],
      description: snapshot.data["description"],
      statut: snapshot.data["statut"],
    );
  }

  // get users stream
  Stream<List<UserModel>> get users {
    return usersCollection.snapshots().map(_usersListFromSnapshot);
  }

  // get user doc stream
  Stream<UserData> get userData {
    return usersCollection.document(uid).snapshots().map(_userDataFromSnapshot);
  }

  // get document of user by his username
  Future getUserByUsername(String username) async {
    return await Firestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .getDocuments();
  }

  // get document of user by his uid
  Future getUserByUid(String uid) async {
    return await Firestore.instance
        .collection("messages")
        .where("uid", isEqualTo: uid)
        .getDocuments();
  }

  //! The Friends :

  // Send a friend request
  Future sendFriendRequest(UserModel userReceiver, UserModel userSender) async {
    bool requestAlreadyExist;
    await Firestore.instance
        .document("users/${userReceiver.uid}/friend_request/${userSender.uid}")
        .get()
        .then((doc) {
      if (doc.exists)
        requestAlreadyExist = true;
      else
        requestAlreadyExist = false;
    });
    //print(requestAlreadyExist);

    if (!requestAlreadyExist) {
      print("A friend request has been sent to this user.");
      await Firestore.instance
          .collection("users/${userReceiver.uid}/friend_request")
          .document(userSender.uid)
          .setData({
        "username": userSender.username,
        "description": userSender.description,
        "uid": userSender.uid,
        "statut": userSender.statut,
      });
    } else {
      print("You have already send a friend request to this user.");
      return "already sent";
    }
  }

  // Accept/Refuse a friend request
  Future accept_refuse_friend_request(UserModel userMe, UserModel userSender, bool accept) async {
    // See if document of userSender exist
    bool friendRequestExist;
    await Firestore.instance
        .document("users/${userMe.uid}/friend_request/${userSender.uid}")
        .get()
        .then((doc) {
      if (doc.exists)
        friendRequestExist = true;
      else
        friendRequestExist = false;
    });
    //print(friendRequestExist);

    if (friendRequestExist && accept) {
      // Paste document
      await Firestore.instance
          .collection("users/${userMe.uid}/all_friends")
          .document(userSender.uid)
          .setData({
        "uid": userSender.uid,
        "description": userSender.description,
        "username": userSender.username,
        "statut": userSender.statut,
      }).catchError((e) => print(e.toString()));

      // And delete the document
      await Firestore.instance
          .document("users/${userMe.uid}/friend_request/${userSender.uid}")
          .delete()
          .catchError((e) => print(e.toString()));

      await Firestore.instance
          .collection("users/${userSender.uid}/all_friends")
          .document(userMe.uid)
          .setData({
        "uid": userMe.uid,
        "description": userMe.description,
        "username": userMe.username,
        "statut": userMe.statut,
      }).catchError((e) => print(e.toString()));
    } else if (friendRequestExist && !accept) {
      // Delete the document
      await Firestore.instance
          .document("users/${userMe.uid}/friend_request/${userSender.uid}")
          .delete()
          .catchError((e) => print(e.toString()));
      return "friend request refuse";
    } else {
      return "no friend request";
    }
  }

  // get friend requests
  Future getAllFriendRequests(UserModel user) async {
    QuerySnapshot resultFriendRequests;
    await Firestore.instance
        .collection("users/${user.uid}/friend_request")
        .getDocuments()
        .then((snapshot) {
      resultFriendRequests = snapshot;
    }).catchError((e) {
      return "no friend requests";
    });
    return resultFriendRequests;
  }

  // get all friends
  Future getAllFriends(UserModel user) async {
    QuerySnapshot resultFriendRequests;
    await Firestore.instance
        .collection("users/${user.uid}/all_friends")
        .getDocuments()
        .then((snapshot) {
      resultFriendRequests = snapshot;
    }).catchError((e) {
      return "no friend";
    });
    return resultFriendRequests;
  }

  // know if a user is your friend
  Future isUserAFriend(UserModel user, UserModel userMe) async {
    // See if collection with friends exist
    bool friendRequestsExist;
    await Firestore.instance
        .document("users/${userMe.uid}/all_friends/${user.uid}")
        .get()
        .then((doc) {
      if (doc.exists)
        friendRequestsExist = true;
      else
        friendRequestsExist = false;
    });
    return friendRequestsExist;
  }

  //! The messages: 

  Future choiceBetweenChatRoom(UserModel userMe, UserModel userReceiver) async {

    bool existUserMeUserReceiver, existUserReceiverUserMe;
    try {
      await Firestore.instance.collection("all_messages")
        .document("${userMe.uid}_${userReceiver.uid}").get()
        .then((doc) {
          if (doc.exists) {
            existUserMeUserReceiver = true;
          } else {
            existUserMeUserReceiver = false;
          }
        });
      
      await Firestore.instance.collection("all_messages")
        .document("${userReceiver.uid}_${userMe.uid}").get()
        .then((doc) {
          if (doc.exists) {
            existUserReceiverUserMe = true;
          } else {
            existUserReceiverUserMe = false;
          }
        });

      if (existUserReceiverUserMe) {
        return false;
      } else if (existUserMeUserReceiver) {
        return true;
      } else {
        await Firestore.instance.collection("all_messages")
          .document("${userMe.uid}_${userReceiver.uid}").setData({
            "id": "${userMe.uid}_${userReceiver.uid}",
            "members": [userMe.uid, userReceiver.uid]
          });
        return true;
      }

    } catch (e) {
      print(e.toString());
    }
  }

  Future getAllMessages(UserModel userMe, UserModel userReceiver) async {

    bool switchBCR = await DatabaseService().choiceBetweenChatRoom(userMe, userReceiver);
    QuerySnapshot resultGetAllMessages;

    if (switchBCR) {

      await Firestore.instance.collection("all_messages/${userMe.uid}_${userReceiver.uid}/chats")
        .getDocuments().then((value) {
          resultGetAllMessages = value;
        });

      return resultGetAllMessages;

    } else {

      await Firestore.instance.collection("all_messages/${userReceiver.uid}_${userMe.uid}/chats")
        .getDocuments().then((value) {
          resultGetAllMessages = value;
        });

      return resultGetAllMessages;

    }
  }

  Future sendMessage(UserModel userMe, UserModel userReceiver, String message) async {

    bool switchBCR = await DatabaseService().choiceBetweenChatRoom(userMe, userReceiver);
    DateTime dateNow = DateTime.now();
    print(dateNow);
    
    if (switchBCR) {

      await Firestore.instance.collection("all_messages/${userMe.uid}_${userReceiver.uid}/chats")
        .document("Message$dateNow").setData({
          "message": message,
          "uid" : userMe.uid, 
          "sendAt": dateNow
        });

    } else {

      await Firestore.instance.collection("all_messages/${userReceiver.uid}_${userMe.uid}/chats")
        .document("Message$dateNow").setData({
          "message": message,
          "uid" : userMe.uid, 
          "sendAt": dateNow
        });

    }

  }

}
