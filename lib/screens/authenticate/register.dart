import 'package:flutter/material.dart';
import 'package:discord_my_version/services/auth.dart';
import 'package:discord_my_version/shared/constants.dart';
import 'package:discord_my_version/shared/loading.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0.0,
        title: Text("Register in to the Project"),
        actions: [
          FlatButton.icon(onPressed: () {_auth.signInAnon();}, icon: Icon(Icons.person), label: Text("Anonymos")),
          FlatButton(onPressed: () {widget.toggleView();}, child: Text("Sign in")),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20,),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: "Email"),
                validator: (val) => val.isEmpty ? "Enter an email" : null,
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(height: 20,),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: "Password"),
                validator: (val) => val.length < 6 ? "Enter a longer password" : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(height: 20,),
              RaisedButton(onPressed: () async {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    loading = true;
                  });
                  dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                  if (result == null) {
                    setState(() {
                      loading = false;
                      error = "Please supply a valid email";
                    });
                  }
                }
              },
                color: Colors.blueAccent,
                child: Text("Register", style: TextStyle(color: Colors.white, fontSize: 20))

              ),
              SizedBox(height: 20,),
              Text(error, style: TextStyle(color: Colors.red, fontSize: 14),)

            ],
          ),
        ),
      ),
    );
  }
}
