import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

class AuthClass {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child("Users");
  final DatabaseReference _orderRef =
      FirebaseDatabase.instance.reference().child("Orders");

  String getCurrentUser() {
    return _auth.currentUser.uid;
  }

  Future<String> registerWithEmailAndPassword(
      String fname, String lname, String email, String password) async {
    Map<String, String> userInfo = {
      "first_name": fname,
      "last_name": lname,
      "email": email
    };
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      String _uid = result.user.uid;
      await _userRef.child(_uid).set(userInfo);
      return "";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return "Registration Failed";
    }
  }

  Future<String> signInwithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
  }

  Future<bool> isUserLoggedIn() async {
    if (_auth.currentUser != null) {
      return true;
    }
    return false;
  }

  bool isLoggedIn(){
    if (_auth.currentUser != null) {
      return true;
    }
    return false;
  }

  signOut() async {
    await _auth.signOut();
  }

  Future<String> postAd(String price, String title, String description,
      String category, String condition) async {
    Map<String, dynamic> orderDetail = {
      "title": title,
      "description": description,
      "price": price,
      "category": category,
      "condition": condition,
      "user": _auth.currentUser.uid,
      "likes": "0",
      "interested_users": {"dummy": true},
      "comments": {"dummy": "dummy"},
      "is_available": true
    };
    try {
      String _uid = _auth.currentUser.uid;
      String oid = await _orderRef.push().key;
      await _orderRef.child(category).child(oid).set(orderDetail);
      await _userRef
          .child(_uid)
          .child("orders")
          .child(oid)
          .set({"category": category});
      return oid;
    } catch (e) {
      return "";
    }
  }

  Future<bool> uploadImage(String oid, String category, File image) async {
    try {
      String path = "order_images/" + oid;
      final storage = firebase_storage.FirebaseStorage.instance;
      await storage.ref().child(path).putFile(image);
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(path)
          .getDownloadURL();
      await _orderRef
          .child(category)
          .child(oid)
          .update({"imageURL": downloadURL});
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map<String, dynamic>> getAdsbyCategory(String category) async {
    var data;
    String key;
    await _orderRef.child(category).once().then((DataSnapshot snapshot) {
      data = jsonEncode(snapshot.value);
      key = snapshot.key;
    });
    Map<String, dynamic> posts = jsonDecode(data);
    return posts;
  }

  Future<Map<String, dynamic>> getOrderDetails(
      String oid, String category) async {
    var data;
    String key;
    await _orderRef
        .child(category)
        .child(oid)
        .once()
        .then((DataSnapshot snapshot) {
      data = jsonEncode(snapshot.value);
      key = snapshot.key;
    });
    Map<String, dynamic> posts = jsonDecode(data);
    return posts;
  }

  Future<Map<String, dynamic>> getUserDetails(String uid) async {
    var data;
    await _userRef.child(uid).once().then((DataSnapshot snapshot) {
      data = jsonEncode(snapshot.value);
    });
    Map<String, dynamic> user = jsonDecode(data);
    return user;
  }

  Future<bool> addToInterested(String oid, String category) async {
    String userID = _auth.currentUser.uid;
    int likes;
    try {
      await _orderRef
          .child(category)
          .child(oid)
          .child("interested_users")
          .update({userID: true});
      await _orderRef
          .child(category)
          .child(oid)
          .child("likes")
          .once()
          .then((DataSnapshot snapshot) {
        likes = int.parse(snapshot.value.toString()) + 1;
      });
      await _orderRef
          .child(category)
          .child(oid)
          .update({"likes": likes.toString()});
      await _userRef
          .child(userID)
          .child("interested_in")
          .update({oid: category});
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<bool> removeFromInterested(String oid, String category) async {
    String userID = _auth.currentUser.uid;
    int likes;
    try {
      await _orderRef
          .child(category)
          .child(oid)
          .child("interested_users")
          .child(userID)
          .remove();
      await _orderRef
          .child(category)
          .child(oid)
          .child("likes")
          .once()
          .then((DataSnapshot snapshot) {
        likes = int.parse(snapshot.value.toString()) - 1;
      });
      await _orderRef
          .child(category)
          .child(oid)
          .update({"likes": likes.toString()});
      await _userRef.child(userID).child("interested_in").child(oid).remove();
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<bool> postComment(String oid, String category, String comment) async {
    String userID = _auth.currentUser.uid;
    try {
      Map<String, dynamic> user = await this.getUserDetails(userID);
      await _orderRef.child(category).child(oid).child("comments").push().set({
        "first_name": user["first_name"],
        "last_name": user["last_name"],
        "comment": comment
      });
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<bool> completeItemPurchase(
      String oid, String category, String owner) async {
    String userID = _auth.currentUser.uid;
    try {
      await _orderRef
          .child(category)
          .child(oid)
          .update({"is_available": false});
      await _userRef.child(userID).child("purchased").update({oid: category});
      await _userRef.child(owner).child("sold").update({oid: category});
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getMyAds() async {
    var data;
    String userID = _auth.currentUser.uid;
    await _userRef
        .child(userID)
        .child("orders")
        .once()
        .then((DataSnapshot snapshot) {
      data = jsonEncode(snapshot.value);
    });
    Map<String, dynamic> posts = jsonDecode(data);
    return posts;
  }

  Future<Map<String, dynamic>> getMyPurchased() async {
    var data;
    String userID = _auth.currentUser.uid;
    await _userRef
        .child(userID)
        .child("purchased")
        .once()
        .then((DataSnapshot snapshot) {
      data = jsonEncode(snapshot.value);
    });
    Map<String, dynamic> posts = jsonDecode(data);
    return posts;
  }
}
