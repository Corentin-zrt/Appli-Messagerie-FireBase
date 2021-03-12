import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/models/user_model.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:discord_my_version/shared/loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:discord_my_version/services/firebase_messaging.dart';
import 'package:discord_my_version/models/message.dart';
import 'package:provider/provider.dart';

class PagePrivateConv extends StatefulWidget {
  final UserModel userReceiver;
  PagePrivateConv({this.userReceiver});
  @override
  _PagePrivateConvState createState() => _PagePrivateConvState();
}

class _PagePrivateConvState extends State<PagePrivateConv> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  //final TextEditingController titleController =
      //TextEditingController(text: "userData.username");
  final TextEditingController bodyController =
      TextEditingController(text: 'Body123');
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();

    _firebaseMessaging.subscribeToTopic('all');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  ScrollController _scrollController = new ScrollController();
  void go_bottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
                      children: messages.map(buildMessage).toList()
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
                            onChanged: (String string) async {
                              //await sendNotification(userMe);
                            },
                            onSubmitted: (String string) async {
                              await sendNotification(userMe);
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
                            controller: bodyController,
                            onTap: go_bottom,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          iconSize: 25,
                          color: Colors.black,
                          onPressed: () async {
                              if (bodyController.text != "" || bodyController.text != " ") {
                                await sendNotification(userMe);
                              }
                            }
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

  Widget buildMessage(Message message) => ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );

  Future sendNotification(UserModel userSender) async {
    String text = bodyController.text;
    bodyController.clear();
    final response = await Messaging.sendToAll(
      title: userSender.username,
      body: text,
    );

    if (response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }
}