import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:discord_my_version/shared/constants.dart';
import 'package:discord_my_version/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageAccount extends StatefulWidget {

  final Function toggleView;
  PageAccount({this.toggleView});

  @override
  _PageAccountState createState() => _PageAccountState();
}

class _PageAccountState extends State<PageAccount> {

  String username, description, statut;
  final List<String> statuts = ["Active", "Offline"];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data;
          return Scaffold(
            body: Container(
              child: Center(
                child: Column(

                  children: [
                    SizedBox(height: 60,),
                    TextFormField(
                      initialValue: userData.username,
                      decoration: textInputDecoration,
                      validator: (val) => val.isEmpty ? "Enter a username" : null,
                      onChanged: (val) {
                        setState(() {
                          username = val;
                        });
                      },
                    ),

                    SizedBox(height: 20,),
                    TextFormField(
                      initialValue: userData.description,
                      decoration: textInputDecoration,
                      validator: (val) => val.isEmpty ? "Enter a description" : null,
                      onChanged: (val) {
                        setState(() {
                          description = val;
                        });
                      },
                    ),

                    SizedBox(height: 20,),
                    DropdownButtonFormField(items: statuts.map((item) {
                      return DropdownMenuItem(child: Text("$item"), value: item);
                    }).toList(), onChanged: (val) {
                      statut = val;
                    }, hint: Text(userData.statut, style: new TextStyle(fontSize: 15),), decoration: textInputDecoration, isExpanded: true,),

                    SizedBox(height: 20,),
                    RaisedButton(onPressed: () async {
                        await DatabaseService(uid: user.uid).updateUserData(username ?? userData.username, description ?? userData.description, statut ?? userData.statut, user.uid);
                        widget.toggleView(3, false, null);
                      },
                      child: Text("Save", style: TextStyle(fontSize: 18)),
                      color: Colors.blue,
                    ),
                  ],

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