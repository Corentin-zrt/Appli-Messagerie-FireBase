import 'package:discord_my_version/models/user_model.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_tile.dart';

class UsersList extends StatefulWidget {
  final Function toggleView;
  UsersList({ this.toggleView });

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {

  bool haveUserSearched = false;
  QuerySnapshot searchResultSnapshot;
  initiateSearch() async {
    if(searchEditingController.text.isNotEmpty){
      await DatabaseService().getUserByUsername(usernameSearch)
          .then((snapshot){
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          haveUserSearched = true;
        });
      });
    } else {
      setState(() {
        haveUserSearched = false;
      });
    }
  }

  TextEditingController searchEditingController = new TextEditingController();

  String usernameSearch = "";
  int userNumber = 0;

  @override
  Widget build(BuildContext context) {

    final users = Provider.of<List<UserModel>>(context) ?? [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.greenAccent,
        body: Container(
          margin: EdgeInsets.only(left: 10, top: 50),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10),
                color: Colors.black54,
                child: TextField(
                  onChanged: (String val) {
                    setState(() {
                      usernameSearch = val;
                    });
                  },
                  onSubmitted: (String val) async {
                    initiateSearch();
                  },
                  controller: searchEditingController,
                  decoration: InputDecoration(
                    hintText: "search username ...",
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    border: InputBorder.none
                  ),
                ),
              ),
              
              Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height - 100,
                child: haveUserSearched ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResultSnapshot.documents.length,
                  itemBuilder: (context, index){
                    UserModel user = UserModel(
                      username: searchResultSnapshot.documents[index].data["username"],
                      description: searchResultSnapshot.documents[index].data["description"],
                      statut: searchResultSnapshot.documents[index].data["statut"],
                      uid: searchResultSnapshot.documents[index].data["uid"],
                    );
                    return UserTile(
                      user: user,
                      toggleView: widget.toggleView
                    );
                  }) : ListView(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  children: usersFromFireBase(users)
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> usersFromFireBase(List<UserModel> users) {
    List<Widget> l = [];
    users.forEach((element) {
      UserTile userTile = new UserTile(user: element, toggleView: widget.toggleView,);
      l.add(userTile);
    });

    return l;
  }
}
