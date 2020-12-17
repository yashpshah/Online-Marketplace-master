import 'package:marketplace/CategoriesProvider.dart';
import 'package:marketplace/ShowPosts.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ShowCategory extends StatefulWidget {
  @override
  _ShowCategoryState createState() => _ShowCategoryState();
}

class _ShowCategoryState extends State<ShowCategory> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString("assets/categories.json"),
      builder: (context, snapshot){
       if(snapshot.connectionState == ConnectionState.done){
         CategoryProvider.cp.setCategory(json.decode(snapshot.data.toString())['categories']);
         return GridView.count(
           padding: EdgeInsets.all(4.0),
           crossAxisCount: 2,
           childAspectRatio: 0.80,
           shrinkWrap: true,
           children: List.generate(CategoryProvider.cp.category.length, (index) {
             return InkWell(
               onTap: (){
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                       builder: (context) => ShowPosts(CategoryProvider.cp.category[index])),
                 );
               },
               child: Center(
                     child: Card(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Expanded(
                               flex: 3, child: Image.asset("assets/"+(index+1).toString()+".png",
                           )
                           ),
                           Expanded(flex: 1,
                               child: Text(CategoryProvider.cp.category[index]))
                         ],
                       ),
                     )),
             );
           }),
         );
       }else{
         return Center(child: CircularProgressIndicator());
       }
      }
    );
  }
}
