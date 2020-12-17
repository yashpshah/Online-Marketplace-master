import 'package:marketplace/PostDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/services/auth.dart';

/* This class loads the image for a particular nickname or hashhag depending on showPostsfromNickName parameter, if true, load image for nickname else load image for hashtags */

class ShowPosts extends StatefulWidget {
  String
      category; //if true, load posts for nickname else load posts for hashtag

  ShowPosts(this.category);

  @override
  _ShowPostsState createState() => _ShowPostsState();
}

class _ShowPostsState extends State<ShowPosts> {
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

  Widget _loadPostText(Map ad) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              "\$" + ad["price"],
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              ad["title"],
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "Item Condition : " + ad["condition"],
              style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "Liked by " + ad['likes'] + " people",
              style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadAds(List<String> orderIDs, List<dynamic> orderDetails) {
    return ListView.builder(
        itemCount: orderIDs != null ? orderIDs.length : 0,
        itemBuilder: (context, index) {
          // print("Post Details : "+ orderIDs[index].toString());
          return orderDetails[index]["is_available"]
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailedPost(
                              orderIDs[index].toString(), widget.category)),
                    ).then((value) => setState(() {}));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 0.0),
                    child: Card(
                      elevation: 10.0,
                      margin: EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _loadImage(orderDetails[index]["imageURL"]),
                          _loadPostText(orderDetails[index])
                        ],
                      ),
                    ),
                  ),
                )
              : Container();
        });
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
          future: AuthClass().getAdsbyCategory(widget.category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null && snapshot.data.length > 0) {
                List<String> orderIDs = snapshot.data.keys.toList();
                List<dynamic> orderDetails = snapshot.data.values.toList();
                return _loadAds(orderIDs, orderDetails);
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.image_aspect_ratio),
                      ),
                      Text(
                        "No items found",
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
