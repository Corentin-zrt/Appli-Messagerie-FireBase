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
      setState(() {
        isAFriend = value;
      });
      //print(isAFriend);
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
              child: Card(
                margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: ListTile(
                  leading: widget.user.statut == "Offline" ? CircleAvatar(radius: 25, backgroundColor: Colors.red) : CircleAvatar(radius: 25, backgroundColor: Colors.blue),
                  title: Text(widget.user.username),
                  subtitle: Text("${descriptionSize(userData.description)}"),
                  trailing: widget.user.username == userData.username ? null : IconButtonPerso(isAFriend: isAFriend, userMe: userMe, user: widget.user, snackUserAdd: snackUserAdd, toggleView: widget.toggleView)
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

class IconButtonPerso extends StatefulWidget {
  final bool isAFriend;
  final UserModel userMe, user;
  final Function snackUserAdd, toggleView;

  IconButtonPerso({ this.isAFriend, this.user, this.userMe, this.snackUserAdd, this.toggleView });

  @override
  _IconButtonPersoState createState() => _IconButtonPersoState();
}

class _IconButtonPersoState extends State<IconButtonPerso> {

  Icon icon;
  Function function;

  @override
  Widget build(BuildContext context) {
    if (widget.isAFriend) {
      setState(() {
        icon = Icon(Icons.message, color: Colors.black,);
        function = () {
          widget.toggleView(2, true, widget.user); 
        };
      });
    } else if (widget.isAFriend == null || widget.isAFriend == false) {
      setState(() {
        icon = Icon(Icons.person_add, color: Colors.black,);
        function = () async {
          dynamic result = await DatabaseService().sendFriendRequest(widget.user, widget.userMe);
          //isAlreadyFriend ? Icon(Icons.message, color: Colors.black,) : 
          if (result == "already sent") {
            widget.snackUserAdd("You have already send a friend request to this user.");
          } else {
            widget.snackUserAdd("A friend request has been sent to this user.");
          }         
        };
      });
    } else {
      setState(() {
        icon = Icon(Icons.person_add, color: Colors.black,);
        function = () async {
          dynamic result = await DatabaseService().sendFriendRequest(widget.user, widget.userMe);
          //isAlreadyFriend ? Icon(Icons.message, color: Colors.black,) : 
          if (result == "already sent") {
            widget.snackUserAdd("You have already send a friend request to this user.");
          } else {
            widget.snackUserAdd("A friend request has been sent to this user.");
          }         
        };
      });
    }

    return IconButton(icon: icon, onPressed: function);
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
                  leading: widget.user.statut == "Active" ? CircleAvatar(radius: 25, backgroundColor: Colors.blue) : CircleAvatar(radius: 25, backgroundColor: Colors.red),
                  title: Text(widget.user.username),
                  subtitle: Text("${descriptionSize(userData.description)}"),
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


class FriendRequestTile extends StatefulWidget {

  final UserModel user_;

  FriendRequestTile({ this.user_ });

  @override
  _FriendRequestTileState createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends State<FriendRequestTile> {

  void snackUserAdd(String text) {
    SnackBar snackBar = new SnackBar( // Faire une notif en bas de l'écran
      content: Text(text),
      duration: new Duration(seconds: 2), // Changer le temps d'apparition de la snackbar
      backgroundColor: Colors.blue,
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

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
              child: Card(
                child: Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.user_.statut == "Active" ? CircleAvatar(radius: 25, backgroundColor: Colors.blue) : CircleAvatar(radius: 25, backgroundColor: Colors.red),
                      Column(
                        children: [
                          Text(widget.user_.username),
                          Text("${descriptionSize(widget.user_.description)}"),
                        ]
                      ),
                      CustomIconButton(userSender: widget.user_),
                    ],
                  ),
                )
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

class CustomIconButton extends StatefulWidget {
  final UserModel userSender;

  CustomIconButton({ this.userSender });

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {

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

          return Row(
            children: [
              IconButton(icon: Icon(Icons.check), onPressed: () async {
                await DatabaseService().accept_refuse_friend_request(userMe, widget.userSender, true);
              }), 
              IconButton(icon: Icon(Icons.remove), onPressed: () async {
                await DatabaseService().accept_refuse_friend_request(userMe, widget.userSender, false);
              }),
            ],
          );
        } else {
          return Loading();
        }   
        
      }
    );
  }

}