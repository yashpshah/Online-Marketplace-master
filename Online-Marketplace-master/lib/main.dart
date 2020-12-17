import 'package:firebase_core/firebase_core.dart';
import 'package:marketplace/LoginPage.dart';
import 'package:marketplace/MarketPlaceFeed.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/MyOrders.dart';
import 'package:marketplace/Signup.dart';
import 'package:marketplace/services/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    this.isLoggedIn = AuthClass().isLoggedIn();
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  // ignore: unused_field
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Builder(
      builder: (context) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("MarketPlace"),
            backgroundColor: Colors.black,
            actions: [
              isLoggedIn
                  ? IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyOrders(),
                            ));
                      })
                  : Container(),
              isLoggedIn
                  ? IconButton(
                      icon: Icon(Icons.arrow_left),
                      onPressed: () {
                        AuthClass().signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      })
                  : Container()
            ],
          ),
          body: FutureBuilder(
              future: AuthClass().isUserLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    return InstaPostFeed();
                  } else {
                    return Signup();
                  }
                } else {
                  return SimpleDialog(
                      backgroundColor: Colors.black,
                      children: <Widget>[
                        Center(
                          child: Column(children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Please wait",
                              style: TextStyle(color: Colors.white),
                            )
                          ]),
                        )
                      ]);
                }
              })),
    ));
  }
}
