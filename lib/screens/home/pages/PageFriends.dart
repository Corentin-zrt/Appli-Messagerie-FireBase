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
  List l2 = [];

  Future initial(UserModel userMe) async {
    await DatabaseService().getAllFriends(userMe).then((value) {

      if (value != null) {
        setState(() {
          l = value.documents;
        });
      }

    });
    await DatabaseService().getAllFriendRequests(userMe).then((value) {

      if (value != null) {
        setState(() {
          l2 = value.documents;
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
                  SizedBox(height: 20),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: l.length,
                    itemBuilder: (context, index) {
                      UserModel user2 = UserModel(
                        username: l[index].data["username"],
                        description: l[index].data["description"],
                        uid: l[index].data["uid"],
                      );
                      if (l.isEmpty || l == []) {
                        return Text("You have no friends 😢", style: TextStyle(color: Colors.black, fontSize: 15),);
                      } else {
                        return FriendTile(
                          user: user2,
                          toggleView: widget.toggleView
                        );
                      }
                    }
                  ),

                  SizedBox(height: 20),
                  Divider(thickness: 5, color: Colors.black),
                  SizedBox(height: 20),
                  Text("Friend Request :", style: TextStyle(color: Colors.black, fontSize: 20),),
                  SizedBox(height: 20),


                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: l2.length,
                    itemBuilder: (context, index) {
                      UserModel user2 = UserModel(
                        username: l2[index].data["username"],
                        description: l2[index].data["description"],
                        uid: l2[index].data["uid"],
                      );
                      print(l2);
                      if (l2.isEmpty || l2 == []) {
                        return Text("You have no friends 😢", style: TextStyle(color: Colors.black, fontSize: 15),);
                      } else {
                        return FriendRequestTile(
                          user_: user2,
                        );
                      }
                    }
                  ),

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