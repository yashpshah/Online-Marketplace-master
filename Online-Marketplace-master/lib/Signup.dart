

import 'package:flutter/material.dart';
import 'package:marketplace/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoadingScreen.dart';
import 'LoginPage.dart';
import 'constants.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String _firstName = "",
      _lastName = "",
      _email = "",
      _password = "",
      _confirmPassword = "",
      _pendingPostMessage = "Checking for pending posts";
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  //Check if user is logged in by checking the sharedpreferences data
  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool response = prefs.getBool("USER_LOGGED_IN");
    if (response) {
      _email = prefs.getString("EMAIL");
      _password = prefs.getString("PASSWORD");
    }
    print("Response: " + response.toString()); //Debug message
    return response;
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  decoration:
                  InputDecoration(labelText: FIRST_NAME),
                  validator: (value) {
                    if (value.isEmpty) {
                      return ERROR_TEXT;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _firstName = value;
                  },
                ),
                TextFormField(
                  decoration:
                  InputDecoration(labelText: LAST_NAME),
                  validator: (value) {
                    if (value.isEmpty) {
                      return ERROR_TEXT;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _lastName = value;
                  },
                ),
                TextFormField(
                  decoration:
                  InputDecoration(labelText: EMAIL),
                  validator: (value) {
                    if (value.isEmpty) {
                      return ERROR_TEXT;
                    } else if (validateEmail(value) ==
                        false) {
                      return "Email ID is invalid";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value;
                  },
                ),
                TextFormField(
                  decoration:
                  InputDecoration(labelText: PASSWORD),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return ERROR_TEXT;
                    } else if (value.length < 3) {
                      return "Password length must be at least 3";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: CONFIRM_PASSWORD),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return ERROR_TEXT;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _confirmPassword = value;
                  },
                ),
                Builder(
                  builder: (context) => Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(5.0),
                          child: Column(children: [
                            RaisedButton(
                                color: Theme.of(context)
                                    .dividerColor,
                                onPressed: () {
                                  if (_formKey.currentState
                                      .validate()) {
                                    _formKey.currentState
                                        .save();
                                    if (_password ==
                                        _confirmPassword) {
                                      Dialogs
                                          .showLoadingDialog(
                                          context,
                                          _keyLoader);
                                      AuthClass().registerWithEmailAndPassword(
                                          _firstName, _lastName,
                                          _email,
                                          _password)
                                          .then((value) {
                                        if (value == "") {
                                          Navigator.of(
                                              _keyLoader
                                                  .currentContext,
                                              rootNavigator:
                                              true)
                                              .pop();
                                          final snackBar = SnackBar(
                                              content: Text(
                                                  "Signup successful. Please log in"));
                                          Scaffold.of(context)
                                              .showSnackBar(
                                              snackBar);
                                        } else {
                                          Navigator.of(
                                              _keyLoader
                                                  .currentContext,
                                              rootNavigator:
                                              true)
                                              .pop();
                                          final snackBar =
                                          SnackBar(
                                              content: Text(
                                                  value.toString()));
                                          Scaffold.of(context)
                                              .showSnackBar(
                                              snackBar);
                                        }
                                      });
                                    } else {
                                      final snackBar = SnackBar(
                                          content: Text(
                                              "Confirm password must match with Password"));
                                      Scaffold.of(context)
                                          .showSnackBar(
                                          snackBar);
                                    }
                                  }
                                },
                                child: Text("Sign Up")),
                            RaisedButton(
                                color: Theme.of(context)
                                    .dividerColor,
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LoginPage()),
                                  );
                                  //TODO
                                },
                                child: Text("Login")),
                          ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
