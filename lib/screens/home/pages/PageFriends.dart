import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/models/user_model.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:discord_my_version/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../user_tile.dart';

class PageFriends extends StatefulWidget {

  final Function toggleView;
  PageFriends({ this.toggleView });

  @override
  _PageFriendsState createState() => _PageFriendsState();
}

class _PageFriendsState extends State<PageFriends> {
  
  List l = [];
  int nbL;

  Future initial(UserModel userMe) async {
    await DatabaseService().getAllFriends(userMe).then((value) {

      if (value != null) {
        setState(() {
          nbL = value.documents.length;
          l = value.documents;
        });
      }
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
          
          return Scaffold(
            appBar: AppBar(
              title: Text("Friends")
            ),
            body: Container(
              child: Column(
                children: [

                  SizedBox(height: 20),
                  Text("Your friends :", style: TextStyle(color: Colors.black, fontSize: 20),),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: l.length,
                    itemBuilder: (context, index) {
                      UserModel user = UserModel(
                        username: l[index].data["username"],
                        description: l[index].data["description"],
                        uid: l[index].data["uid"],
                      );
                      if (l.isEmpty) {
                        return Text("You have no friends", style: TextStyle(color: Colors.black, fontSize: 15),);
                      } else {
                        return FriendTile(
                          user: user,
                          toggleView: widget.toggleView
                        );
                      }
                    }
                  ),

                  SizedBox(height: 20),
                  Divider(thickness: 5, color: Colors.black),
                  SizedBox(height: 20),
                  Text("Friend Request :", style: TextStyle(color: Colors.black, fontSize: 20),),

                ]
              )
            ),
          );
        } else {
          return Loading();
        }
        
      }
    );
  }
}