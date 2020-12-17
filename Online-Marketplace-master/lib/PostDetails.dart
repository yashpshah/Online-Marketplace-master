import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/src/material/card.dart' as card;
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';

/* This class shows the single post window containing rating and comments on the posts*/
class DetailedPost extends StatefulWidget {
  String oid, category;

  DetailedPost(this.oid, this.category);

  @override
  _DetailedPostState createState() => _DetailedPostState();
}

class _DetailedPostState extends State<DetailedPost> {
  String comment;
  final _commentFormKey = GlobalKey<FormState>();
  int currentRating = 0;

  _DetailedPostState() {
    WidgetsFlutterBinding.ensureInitialized();
    InAppPayments.setSquareApplicationId(
        "sandbox-sq0idb-j33zwaAPQXUvuXSjgieViA");
  }

  Widget _loadImage(String imageURL) {
    if (imageURL != null) {
      return Image.network(
        imageURL,
        height: 200.0,
        fit: BoxFit.fill,
      );
    } else {
      return Image(image: AssetImage('assets/placeholder_image.png'));
    }
  }

  //Read user credentials from sharedpreferences
  Future<List> _getUserCredentials() async {
    List<String> userCreds = new List();
    final prefs = await SharedPreferences.getInstance();
    userCreds.add(prefs.getString("EMAIL"));
    userCreds.add(prefs.getString("PASSWORD"));
    print(userCreds);
    return userCreds;
  }

  void onCardSuccess(
      CardDetails cardDetails, String owner, BuildContext context) {
    print(cardDetails.nonce); // here you get the nonce
    // The following method dismisses the card entry UI
    // It is required to be called
    InAppPayments.completeCardEntry(onCardEntryComplete: () async {
      bool res = await AuthClass()
          .completeItemPurchase(widget.oid, widget.category, owner);
      if (res == true) {
        final snackBar = SnackBar(content: Text("Transaction completed"));
        Scaffold.of(context).showSnackBar(snackBar);
        print("Transaction completed");
        setState(() {});
      } else {
        final snackBar = SnackBar(content: Text("Transaction failed"));
        Scaffold.of(context).showSnackBar(snackBar);
        print("Transaction failed");
      }

      // code here will be execute after the card entry UI is dismissed
    });
  }

  void onCardCanceled(BuildContext context) {
    final snackBar = SnackBar(content: Text("Transaction cancelled"));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("MarketPlace"),
          backgroundColor: Colors.black,
        ),
        body: FutureBuilder(
          future: AuthClass().getOrderDetails(widget.oid, widget.category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // print(snapshot.data["interested_users"].keys);
              Iterable interested_users =
                  snapshot.data["interested_users"].keys;
              List<String> userIdsFromComments =
                  snapshot.data["comments"].keys.toList();
              List<dynamic> commentTexts =
                  snapshot.data["comments"].values.toList();
              bool availability = snapshot.data["is_available"];
              String owner = snapshot.data["owner"];
              bool isInterested =
                  interested_users.contains(AuthClass().getCurrentUser())
                      ? true
                      : false;
              return SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: card.Card(
                            elevation: 10.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _loadImage(snapshot.data["imageURL"]),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    "\$" + snapshot.data["price"],
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    snapshot.data["title"],
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: RichText(
                                      text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: snapshot.data["likes"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              ' people are interested in this'),
                                    ],
                                  )),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4.0),
                                      child: RaisedButton(
                                        color: isInterested
                                            ? Colors.blue
                                            : Colors.white,
                                        textColor: isInterested
                                            ? Colors.white
                                            : Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                                color: Colors.lightBlue)),
                                        onPressed: () async {
                                          if (isInterested == false) {
                                            bool res = await AuthClass()
                                                .addToInterested(widget.oid,
                                                    widget.category);
                                            if (res == true) {
                                              setState(() {
                                                isInterested = true;
                                              });
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      "Marked as interested"));
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                            } else {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      "Error occurred. Please check your internet connection"));
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                            }
                                          } else {
                                            bool res = await AuthClass()
                                                .removeFromInterested(
                                                    widget.oid,
                                                    widget.category);
                                            if (res == true) {
                                              setState(() {
                                                isInterested = false;
                                              });
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      "Removed from interested"));
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                            } else {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      "Error occurred. Please check your internet connection"));
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                            }
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2.0, 0.0, 4.0, 0.0),
                                              child: Icon(Icons.thumb_up),
                                            ),
                                            Text(
                                              "I am interested",
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(4.0),
                                      child: RaisedButton(
                                        color: Colors.red,
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                                color: Colors.black)),
                                        onPressed: availability
                                            ? () async {
                                                InAppPayments.startCardEntryFlow(
                                                    onCardNonceRequestSuccess:
                                                        (cardDetails) =>
                                                            onCardSuccess(
                                                                cardDetails,
                                                                owner,
                                                                context),
                                                    onCardEntryCancel: () =>
                                                        onCardCanceled(
                                                            context));
                                              }
                                            : null,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2.0, 0.0, 4.0, 0.0),
                                              child:
                                                  Icon(Icons.add_shopping_cart),
                                            ),
                                            Text(
                                              "Buy Now",
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Comments',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Form(
                          key: _commentFormKey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          labelText: "Type your comment.."),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "This field is required";
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        comment = value;
                                      },
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: RaisedButton(
                                      onPressed: () async {
                                        if (_commentFormKey.currentState
                                            .validate()) {
                                          _commentFormKey.currentState.save();
                                          bool res = await AuthClass()
                                              .postComment(widget.oid,
                                                  widget.category, comment);
                                          if (res == true) {
                                            setState(() {
                                              isInterested = isInterested;
                                            });
                                            final snackBar = SnackBar(
                                                content: Text(
                                                    "Comment has been posted"));
                                            Scaffold.of(context)
                                                .showSnackBar(snackBar);
                                          } else {
                                            final snackBar = SnackBar(
                                                content: Text(
                                                    "Error occurred. Please check your network connection"));
                                            Scaffold.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                        }
                                      },
                                      child: Text("Submit"),
                                    ))
                              ],
                            ),
                          ),
                        ),
                        if (userIdsFromComments.length == 1)
                          Text(
                            'No comments found',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        for (int i = 0; i < userIdsFromComments.length; i++)
                          if (userIdsFromComments[i] != "dummy")
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 0.0),
                              child: card.Card(
                                elevation: 5.0,
                                child: ListTile(
                                  subtitle: Text(
                                    "commented by " +
                                        commentTexts[i]["first_name"] +
                                        " " +
                                        commentTexts[i]["last_name"],
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  title: Text(commentTexts[i]["comment"]),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
