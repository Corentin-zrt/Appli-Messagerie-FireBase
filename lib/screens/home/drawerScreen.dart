import 'package:discord_my_version/models/user_class.dart';
import 'package:discord_my_version/models/user_model.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:discord_my_version/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DrawerScreen extends StatefulWidget {

  final Function toggleView;
  DrawerScreen({this.toggleView});

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isMenuMessagerieOpen = false, isMenuServerOpen = false, isMenuCarteOpen = true;
  List<Map> drawerItems=[
    {
      'icon': FontAwesomeIcons.paw, // Remplacer icon par Avatar avec url
      'title' : 'Adoption' 
    },
    {
      'icon': Icons.mail,
      'title' : 'Donation'
    },
    {
      'icon': FontAwesomeIcons.plus,
      'title' : 'Add pet'
    },
    {
      'icon': Icons.favorite,
      'title' : 'Favorites'
    },
    {
      'icon': Icons.mail,
      'title' : 'Messages'
    },
    {
      'icon': FontAwesomeIcons.userAlt,
      'title' : 'Profile'
    },
    {
      'icon': Icons.favorite,
      'title' : 'Favorites'
    },
    {
      'icon': Icons.mail,
      'title' : 'Messages'
    },
    {
      'icon': FontAwesomeIcons.userAlt,
      'title' : 'Profile'
    },
  ];

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
          
          return Scaffold(
            body: Container(
              color: Colors.greenAccent,
              padding: EdgeInsets.only(top:50, left: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      print("open account");
                      widget.toggleView(0, false, null);
                    },
                    child: Row(
                      children: [
                        userData.statut == "Offline" ? CircleAvatar(backgroundColor: Colors.red,) : CircleAvatar(backgroundColor: Colors.blue,),
                        SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userData.username, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
                            Text(userData.statut, style: TextStyle(color: Colors.white, fontSize: 15)),
                            Text(descriptionSize(userData.description), style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        )
                      ],
                    ),
                  ),

                  Container(
                    height: MediaQuery.of(context).size.height - 200, 
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => (isMenuCarteOpen = !isMenuCarteOpen));
                          },
                          child: Row(
                            children: [
                              Icon(Icons.card_travel, color: Colors.white,size: 30,),
                              SizedBox(width: 10,),
                              Text("My cards",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              isMenuCarteOpen ? Icon(Icons.arrow_drop_down, size: 30, color: Colors.white,) : Icon(Icons.arrow_right, size: 30, color: Colors.white,)
                            ],
                          ),
                        ),

                        isMenuCarteOpen ? Column(
                          // Ici afficher liste des convs
                          children: drawerItems.map((element) { 
                            return GestureDetector(
                              onTap: () {
                                print("open carte with ${element['title']}");
                                widget.toggleView(3, false, null);
                              },
                              child:Container(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  children: [
                                    Icon(element['icon'],color: Colors.white,size: 30,),
                                    SizedBox(width: 10,),
                                    Text(element['title'],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20))
                                  ],

                                ),
                              )
                            );
                          }).toList(),
                        ) : Container(),

                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.toggleView(4, false, null);
                              isMenuMessagerieOpen = !isMenuMessagerieOpen;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.white,size: 30,),
                              SizedBox(width: 10,),
                              Text("Friends",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
                            ],
                          ),
                        ),

                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: () {
                            setState(() => (isMenuServerOpen = !isMenuServerOpen));
                          },
                          child: Row(
                            children: [
                              Icon(Icons.network_cell, color: Colors.white,size: 30,),
                              SizedBox(width: 10,),
                              Text("Servers",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 20)),
                              isMenuServerOpen ? Icon(Icons.arrow_drop_down, size: 30, color: Colors.white,) : Icon(Icons.arrow_right, size: 30, color: Colors.white,)
                            ],
                          ),
                        ),
                        isMenuServerOpen ? Column(
                          // Ici afficher liste des convs
                          children: drawerItems.map((element) { 
                            return GestureDetector(
                              onTap: () {
                                print("open server ${element['title']}");
                                widget.toggleView(1, false, null);
                                /*Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) {
                                  //return new Home(server_name: element['title']);
                                }));*/
                              },
                              child:Container(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  children: [
                                    Icon(element['icon'],color: Colors.white,size: 30,),
                                    SizedBox(width: 10,),
                                    Text(element['title'],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20))
                                  ],

                                ),
                              )
                            );
                          }).toList(),
                        ) : Container(),

                      ],
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.settings, size: 30, color: Colors.white), onPressed: () => widget.toggleView(0, false, null)),
                      SizedBox(width: 10,),
                      FlatButton(onPressed: () async {
                        await _auth.signOut();
                      }, child: Text("Logout", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)))
                    ],
                  ),

                ],
              ),
            ),
          );

        } else {
          return Loading();
        }
        
      }
    );
  }
}