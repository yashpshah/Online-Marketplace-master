import 'package:marketplace/main.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/services/auth.dart';
import 'LoadingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* this class handles login activity for the user */
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "", _password = "";
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Login"),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: "Email"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "This field is required";
                        } else if (validateEmail(value) == false) {
                          return "Email ID is invalid";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "This field is required";
                        } else if (value.length < 3) {
                          return "Password length must be at least 3";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value;
                      },
                    ),
                    Builder(
                      builder: (context) => Column(
                        children: [
                          Container(
                              padding: EdgeInsets.all(5.0),
                              child: RaisedButton(
                                  color: Theme.of(context).dividerColor,
                                  onPressed: () {
                                    print("Button pressed");
                                    if (_formKey.currentState.validate()) {
                                      Dialogs.showLoadingDialog(
                                          context, _keyLoader);
                                      _formKey.currentState.save();
                                      AuthClass().signInwithEmail(_email, _password)
                                          .then((value) {
                                        if (value=="") {
                                          Navigator.of(
                                              _keyLoader.currentContext,
                                              rootNavigator: true)
                                              .pop();
                                          final snackBar = SnackBar(
                                              content:
                                              Text("Login successful"));
                                          Scaffold.of(context)
                                              .showSnackBar(snackBar);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MyApp()),
                                          );
                                        } else {
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                          final snackBar = SnackBar(
                                              content: Text(value));
                                          Scaffold.of(context)
                                              .showSnackBar(snackBar);
                                        }
                                      });
                                    }
                                  },
                                  child: Text("Login"))),
                          Container(
                            padding: EdgeInsets.all(5.0),
                            child: RaisedButton(
                                color: Theme.of(context).dividerColor,
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyApp()),
                                  );
                                  //TODO
                                },
                                child: Text("Sign up")),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
