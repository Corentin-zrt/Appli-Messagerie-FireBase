import 'package:discord_my_version/models/user_model.dart';
import 'package:discord_my_version/screens/home/drawerScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:discord_my_version/services/database.dart';
import 'package:provider/provider.dart';

import 'pages/PageAccount.dart';
import 'pages/PageCarte.dart';
import 'pages/PageFriends.dart';
import 'pages/PagePrivateConversation.dart';
import 'pages/PagePrivateConv.dart';
import 'pages/PageServer.dart';
import 'usersList.dart';

class Home extends StatefulWidget {

  Home({Key key, this.server_name}) : super(key: key);

  String server_name;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  PageAccount _account;
  final PageServer _server = new PageServer();
  var _conversation_private;//PagePrivateConversation _conversation_private;
  final PageCarte _carte = new PageCarte();
  PageFriends _friends = new PageFriends();

  Widget _showPage = PageCarte();

  void toggleView(tappedIndex, go, pageConvPrivateChange) {
    setState(() {
      _showPage = _pageChooser(tappedIndex, pageConvPrivateChange);
      if (go == true) {
        _toggle(false);
      } 
    });
  } 

  Widget _pageChooser(int page, UserModel pageConvPrivateChange) {
    switch(page) {
      case 0:
        setState(() {
          _account = new PageAccount(toggleView: toggleView,);
        });
        return _account;
        break;
      case 1:
        return _server;
        break;
      case 2:
        setState(() {
          _conversation_private = new PagePrivateConv(userReceiver: pageConvPrivateChange,);//new PagePrivateConversation(userReceiver: pageConvPrivateChange,);
        });
        return _conversation_private;
        break;
      case 3:
        return _carte;
        break;
      case 4:
        setState(() {
          _friends = new PageFriends(toggleView: toggleView);
        });
        return _friends;
        break;
      default:
        return _conversation_private;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<UserModel>>.value(
      value: DatabaseService().users,
      child: InnerDrawer(
        key: _innerDrawerKey,
        onTapClose: true, 
        swipe: true,        
        colorTransitionChild: Colors.greenAccent, 
        colorTransitionScaffold: Colors.transparent, 
        
        offset: IDOffset.only(bottom: 0.05, right: 0.6, left: 0.6),
        
        scale: IDOffset.horizontal(0.8), 
        
        proportionalChildArea : true, 
        borderRadius: 50, 
        leftAnimationType: InnerDrawerAnimation.quadratic,
        rightAnimationType: InnerDrawerAnimation.quadratic,
        backgroundDecoration: BoxDecoration(color: Colors.greenAccent), 
        
        leftChild: DrawerScreen(toggleView: toggleView),
        rightChild: UsersList(toggleView: toggleView),
        
        scaffold: _showPage,
      ),
    );
  }

  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();    

  void _toggle(bool sens) {
    if (sens) {
      _innerDrawerKey.currentState.toggle(
        // direction is optional 
        // if not set, the last direction will be used
        // InnerDrawerDirection.start OR InnerDrawerDirection.end                        
        direction: InnerDrawerDirection.start 
      );
    } else {
      _innerDrawerKey.currentState.toggle(
        // direction is optional 
        // if not set, the last direction will be used
        // InnerDrawerDirection.start OR InnerDrawerDirection.end                        
        direction: InnerDrawerDirection.end 
      );
    }
  }
}
