import 'package:flutter/material.dart';
import 'package:marketplace/services/auth.dart';

class MyAds extends StatefulWidget {
  @override
  _MyAdsState createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
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

  Widget _loadPostsForOID(List<String> orderIDs, orderDetails) {
    return ListView.builder(
        itemCount: orderIDs != null ? orderIDs.length : 0,
        itemBuilder: (context, index) {
          return FutureBuilder(
              future: AuthClass().getOrderDetails(
                  orderIDs[index], orderDetails[index]["category"]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 0.0),
                          child: Card(
                            elevation: 10.0,
                            margin: EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _loadImage(snapshot.data["imageURL"]),
                                _loadPostText(snapshot.data)
                              ],
                            ),
                          ),
                        )
                      : Container();
                } else {
                  return Container(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()));
                }
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthClass().getMyAds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null && snapshot.data.length > 0) {
            List<String> orderIDs = snapshot.data.keys.toList();
            List<dynamic> orderCategory = snapshot.data.values.toList();
            return _loadPostsForOID(orderIDs, orderCategory);
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
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
