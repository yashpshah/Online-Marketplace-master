import 'dart:io';
import 'package:marketplace/SelectCategories.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:marketplace/services/auth.dart';
import 'LoadingScreen.dart';

/* This module handles the user's post upload action*/

class MakeAPost extends StatefulWidget {
  @override
  _MakeAPostState createState() => _MakeAPostState();
}

class _MakeAPostState extends State<MakeAPost> {
  File _image;
  String _titleErrorText, _priceErrorText, _itemDescriptionErrorText;
  bool _titleError = false,
      _priceError = false,
      _itemDescriptionError = false,
      isConnected = true;
  String category = "", _postTitle = "", _postDescription = "", _postPrice = "";
  double _currentSliderValue = 0;
  Map<int, String> _condition = {
    0: "Select Condition",
    20: "New (Never Used)",
    40: "Open box (Never Used)",
    60: "Used (Normal wear)",
    80: "Heavily used",
    100: "Needs repair/fix"
  };
  Widget show = Container();
  final priceController = TextEditingController(),
      titleController = TextEditingController(),
      descriptionController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final picker = ImagePicker();

  //Picks the image from user's gallery
  _getImage() async {
    final PickedFile pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 400.0);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.'); //Debug message
      }
    });
  }

  //Validates the post for text and hashtags
  bool _validatePostFields() {
    _postTitle = titleController.text;
    _postDescription = descriptionController.text;
    _postPrice = priceController.text;
    bool error = true;

    if (_postPrice.length == 0) {
      error = false;
      setState(() {
        _priceError = true;
        _priceErrorText = "Price is required";
      });
    } else {
      setState(() {
        _priceError = false;
      });
    }

    //If no text in post
    if (_postTitle.length == 0) {
      error = false;
      setState(() {
        _titleError = true;
        _titleErrorText = "Title is required";
      });
    } else {
      setState(() {
        _titleError = false;
      });
    }

    //If no text in post
    if (_postDescription.length == 0) {
      error = false;
      setState(() {
        _itemDescriptionError = true;
        _itemDescriptionErrorText = "Description is required";
      });
    } else {
      setState(() {
        _itemDescriptionError = false;
      });
    }

    if (_image == null) {
      final snackBar = SnackBar(content: Text("Post must contain an Image"));
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    } else if (_currentSliderValue == 0) {
      final snackBar =
          SnackBar(content: Text("Please select the item's condition"));
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    } else if (category == "") {
      final snackBar = SnackBar(content: Text("Please select category"));
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    }

    return error;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: EdgeInsets.all(6.0),
        height: 200.0,
        child: InkWell(
          onTap: () {
            _getImage();
          },
          child: _image == null
              ? Image.asset("assets/placeholder_image.png")
              : Image.file(_image, fit: BoxFit.fill),
        ),
      ),
      Text("Add Image",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 6.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Enter price you are expecting",
                  errorText: _priceError ? _priceErrorText : null,
                  border: const OutlineInputBorder()),
              keyboardType: TextInputType.number,
              maxLines: null,
              controller: priceController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 2.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Give title to your ad..",
                  errorText: _titleError ? _titleErrorText : null,
                  border: const OutlineInputBorder()),
              maxLength: 100,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: titleController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 2.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Describe your item",
                  errorText:
                      _itemDescriptionError ? _itemDescriptionErrorText : null,
                  border: const OutlineInputBorder()),
              maxLength: 200,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: descriptionController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 8.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Condition of your item: " +
                        _condition[_currentSliderValue.toInt()],
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 100,
                    divisions: 5,
                    label: _condition[_currentSliderValue.toInt()],
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(6.0, 4.0, 6.0, 12.0),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      category == ""
                          ? Text(
                              "Select Category ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            )
                          : Text(
                              "Current Category: " + category,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
                onPressed: () async {
                  var newCat = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectCategory()),
                  );
                  if (newCat != null) {
                    setState(() {
                      category = newCat;
                    });
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.0),
              child: RaisedButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.white)),
                  onPressed: () async {
                    if (_validatePostFields()) {
                      Dialogs.showLoadingDialog(
                          context, _keyLoader); //invoking loading screen
                      String oid = await AuthClass().postAd(
                          _postPrice,
                          _postTitle,
                          _postDescription,
                          category,
                          _condition[_currentSliderValue.toInt()]);
                      await AuthClass().uploadImage(oid, category, _image);
                      final snackBar = SnackBar(content: Text(oid));
                      Scaffold.of(context).showSnackBar(snackBar);
                      Navigator.of(_keyLoader.currentContext,
                              rootNavigator: true)
                          .pop();
                    }
                  },
                  child: Text("Submit",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0))),
            ),
          )
        ],
      )
    ]));
  }
}
