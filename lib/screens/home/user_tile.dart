import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:discord_my_version/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:discord_my_version/models/user_model.dart';
import 'package:provider/provider.dart';

class UserTile extends StatefulWidget {

  final UserModel user;
  final Function toggleView;

  UserTile({ this.user, this.toggleView });
  
  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {

  String descriptionSize(String description) {

    String phrase = "";
    if (description.length >= 25) {
      phrase = "${description.substring(0, 25)}...";
    } else {
      phrase = description;
    }

    return phrase;

  }

  void snackUserAdd(String text) {
    SnackBar snackBar = new SnackBar( // Faire une notif en bas de l'écran
      content: Text(text),
      duration: new Duration(seconds: 2), // Changer le temps d'apparition de la snackbar
      backgroundColor: Colors.blue,
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  bool isAFriend;
  Future initial(UserModel userMe) async {
    await DatabaseService().isUserAFriend(widget.user, userMe).then((value) {
      //print(value);
      isAFriend = value;
      print(isAFriend);
    });
  }
  
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data;
          UserModel userMe = UserModel(
            username: userData.username,
            description: userData.description,
            statut: userData.statut,
            uid: userData.uid,
          );

          initial(userMe); 

          return Padding(
            padding: EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                if (widget.user.username != userData.username) {
                  widget.toggleView(2, true, widget.user);
                }
              },
              child: Card(
                margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: ListTile(
                  leading: widget.user.statut == "Offline" ? CircleAvatar(radius: 25, backgroundColor: Colors.red) : CircleAvatar(radius: 25, backgroundColor: Colors.blue),
                  title: Text(widget.user.username),
                  subtitle: Text("${descriptionSize(userData.description)}"),
                  trailing: widget.user.username == userData.username ? null : iconButtonPerso(isAFriend, userMe)
                ),
              ),
            )
          );
        } else {
          return Loading();
        }        
      }
    );
  }

  Widget iconButtonPerso(bool isAFriend, UserModel userMe) {
    if (isAFriend) {
      return IconButton(icon: Icon(Icons.message, color: Colors.black,), onPressed: () async {
        dynamic result = await DatabaseService().sendFriendRequest(widget.user, userMe);
        if (result == "already sent") {
          snackUserAdd("You have already send a friend request to this user.");
        } else {
          snackUserAdd("A friend request has been sent to this user.");
        }         
      });
    } else if (isAFriend == null) {
      return IconButton(icon: Icon(Icons.person_add, color: Colors.black,), onPressed: () async {
        dynamic result = await DatabaseService().sendFriendRequest(widget.user, userMe);
        //isAlreadyFriend ? Icon(Icons.message, color: Colors.black,) : 
        if (result == "already sent") {
          snackUserAdd("You have already send a friend request to this user.");
        } else {
          snackUserAdd("A friend request has been sent to this user.");
        }         
      });
    } else {
      return IconButton(icon: Icon(Icons.person_add, color: Colors.black,), onPressed: () async {
        dynamic result = await DatabaseService().sendFriendRequest(widget.user, userMe);
        //isAlreadyFriend ? Icon(Icons.message, color: Colors.black,) : 
        if (result == "already sent") {
          snackUserAdd("You have already send a friend request to this user.");
        } else {
          snackUserAdd("A friend request has been sent to this user.");
        }         
      });
    }
  }
}


class FriendTile extends StatefulWidget {

  final UserModel user;
  final Function toggleView;

  FriendTile({ this.user, this.toggleView });
  
  @override
  _FriendTileState createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile> {

  String descriptionSize(String description) {

    String phrase = "";
    if (description.length >= 25) {
      phrase = "${description.substring(0, 25)}...";
    } else {
      phrase = description;
    }

    return phrase;

  }
  
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data;
          UserModel userMe = UserModel(
            username: userData.username,
            description: userData.description,
            statut: userData.statut,
            uid: userData.uid,
          );

          return Padding(
            padding: EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                if (widget.user.username != userData.username) {
                  widget.toggleView(2, true, widget.user);
                }
              },
              child: Card(
                margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: ListTile(
                  leading: widget.user.statut == "Offline" ? CircleAvatar(radius: 25, backgroundColor: Colors.red) : CircleAvatar(radius: 25, backgroundColor: Colors.blue),
                  title: Text(widget.user.username),
                  subtitle: Text("${descriptionSize(userData.description)}"),
                  trailing: IconButton(icon: Icon(Icons.message, color: Colors.black,), onPressed: () async {
                    widget.toggleView(2, false, widget.user);
                  })
                ),
              ),
            )
          );
        } else {
          return Loading();
        }        
      }
    );
  }
}
