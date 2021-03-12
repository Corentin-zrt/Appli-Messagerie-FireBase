import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discord_my_version/models/message_model.dart';
import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/models/user_model.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:discord_my_version/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PagePrivateConversation extends StatefulWidget {

  final UserModel userReceiver;
  PagePrivateConversation({ this.userReceiver });
  @override
  _PagePrivateConversationState createState() => _PagePrivateConversationState();
}

class _PagePrivateConversationState extends State<PagePrivateConversation> {

  String onChange;
  List<Message> all_messages = [];
  TextEditingController _controller = new TextEditingController();

  ScrollController _scrollController = new ScrollController();
  void go_bottom() {
    _scrollController.jumpTo(_scrollController.position.minScrollExtent);
  }

  void envoyer_message(String onChange, userMe, userReceiver) {
    DatabaseService().sendMessage(userMe, userReceiver, onChange);
    onChange = "";
    _controller.clear();
    go_bottom();
  }

  List<DocumentSnapshot> l = [];
  void initial(UserModel userMe) {
    DatabaseService().getAllMessages(userMe, widget.userReceiver).then((value) {
      setState(() {
        l = value.documents;
      });
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
              backgroundColor: Colors.greenAccent,
              title: Text(widget.userReceiver.username)
            ),
            body: Container(
              child: Column(
                children: [
                  // Les messages:
                  Expanded(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      controller: _scrollController,
                      children: MessageContainer(userMe, l),
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
                            onChanged: (String string) {
                              setState(() {
                                onChange = string;
                              });
                            },
                            onSubmitted: (String string) {
                              setState(() {
                                onChange = string;
                                if (onChange != "" || onChange != " ") {
                                  envoyer_message(onChange, userMe, widget.userReceiver);
                                }
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
                              fillColor: Colors.black45
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
                              if (onChange != "" || onChange != " ") {
                                envoyer_message(onChange, userMe, widget.userReceiver);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  )

                ]
              ),
            )
          );
        } else {
          return Loading();
        }
      }
    );
  }

  List MessageContainer(UserModel userMe, List<DocumentSnapshot> l) {

    List<Widget> messages = [];

    messages.add(Text(""));

    if (l != null || l != []) {
      l.forEach((element) {
        Container message;
        if (element.data["uid"] == userMe.uid) {
          DateTime dateSend = element.data["sendAt"].toDate();
          DateFormat formatter = DateFormat('HH:mm dd-MM');
          String formatted = formatter.format(dateSend);

          message = new Container(
            alignment: Alignment.topRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.80,
                  ),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 15, right: 15),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    element.data["message"],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 3,),
                Text(formatted, 
                  style: TextStyle(
                    fontSize: 10, 
                    color: Colors.grey,
                  )
                ),
              ],
            ),
          );
        } else {
          DateTime dateSend = element.data["sendAt"].toDate();
          DateFormat formatter = DateFormat('HH:mm dd-MM');
          String formatted = formatter.format(dateSend);

          message = new Container(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.80,
                  ),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 15, right: 15),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    element.data["message"],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 3,),
                Text(formatted, 
                  style: TextStyle(
                    fontSize: 10, 
                    color: Colors.grey,
                  )
                ),
              ],
            ),
          );
        }

        messages.add(message);
      });

      return messages;
    } else {

      messages.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("  You have no messages with this user.\n  Send the first !", style: TextStyle(color: Colors.black, fontSize: 18))
          ]
        )
      );
      return messages;
    }

  }
}