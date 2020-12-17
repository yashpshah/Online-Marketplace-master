import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marketplace/CategoriesProvider.dart';

class SelectCategory extends StatefulWidget {
  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  List<String> _category = CategoryProvider.cp.category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("MarketPlace"),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: _category.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
            child: Card(
              child: ListTile(
                onTap: () {
                  Navigator.pop(context, _category[index]);
                },
                title: Text(_category[index]),
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/hashtag_placeholder.png'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
