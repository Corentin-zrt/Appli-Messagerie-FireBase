import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discord_my_version/models/message_model.dart';
import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/models/user_model.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:discord_my_version/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PagePrivateConversation extends StatefulWidget {
  final UserModel user;
  PagePrivateConversation({this.user});

  @override
  _PagePrivateConversationState createState() =>
      _PagePrivateConversationState();
}

class _PagePrivateConversationState extends State<PagePrivateConversation> {

  TextEditingController _controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  void go_bottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void envoyer_message(String onChange, UserModel userSender, UserModel userReceiver) async {
    /*await DatabaseService().sendMessage(userReceiver, userSender, onChange);
    onChange = "";
    _controller.clear();
    go_bottom();*/
  }

  String onChange;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    List<Message> messages;

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

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.user.username),
              ),
              body: Container(
                  child: Column(
                    children: [

                      // Les messages:
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          children: MessageContainer(messages, userData),
                        )
                      ),

                      // Champ de saisie:
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                onSubmitted: (String string) {
                                  setState(() {
                                    onChange = string;
                                    //envoyer_message(onChange, userMe, widget.user);
                                  });
                                },
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 10, color: Colors.black),
                                    borderRadius: BorderRadius.all(Radius.circular(45)),
                                  ),
                                  hintText: "Send a message...",
                                  filled: true,
                                  fillColor: Colors.blueAccent
                                ),
                                textCapitalization: TextCapitalization.sentences,
                                controller: _controller,
                                onTap: go_bottom,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              iconSize: 25,
                              color: Colors.black,
                              onPressed: () {
                                setState(() {
                                  if (onChange != "") {
                                    envoyer_message(onChange, userMe, widget.user);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    ]     
                  )
                )
              );
          } else {
            return Loading();
          }
        }
      );
  }

  List<Widget> MessageContainer(messages, UserData userData) {

    List<Widget> l = [];
    messages.forEach((element) {
      Container message;
      if (element.author == userData.username) {
        message = new Container(
          alignment: Alignment.topRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 15, right: 15),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Text(
              element.content,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        message = new Container(
          alignment: Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 15, left: 15),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Text(
              element.content,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
      l.add(message);
    });
    return l;
  }
}
