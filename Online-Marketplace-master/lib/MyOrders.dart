import 'package:flutter/material.dart';
import 'package:marketplace/MyAds.dart';
import 'package:marketplace/MyPurchasedItems.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("My Order History"),
            backgroundColor: Colors.black,
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(maxHeight: 150.0),
                  child: Material(
                    color: Colors.black,
                    //to display tabview at the top of the screen
                    child: TabBar(
                      tabs: [
                        Tab(
                          text: "My Ads",
                        ),
                        Tab(
                          text: "Post",
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [MyAds(), MyPurchasedItems()],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
