import 'package:flutter/material.dart';
import 'home/home.dart';
import 'authenticate/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:discord_my_version/models/user_class.dart';

class SwitcherWidget extends StatefulWidget {
  @override
  _SwitcherWidgetState createState() => _SwitcherWidgetState();
}

class _SwitcherWidgetState extends State<SwitcherWidget> {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}