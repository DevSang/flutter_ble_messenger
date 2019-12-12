import 'package:flutter/material.dart';

class HwaTab extends StatefulWidget {
  @override
  _HwaTabState createState() => _HwaTabState();
}

class _HwaTabState extends State<HwaTab> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       appBar: AppBar(
         title: const Text("단화 목록"),
       ),
           body: Container(
             padding: EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                 Text('Load image from assets',
                   style: TextStyle(fontSize: 18.0),
                 ),
               Image.asset('images/test.png'),

               ],
           ),
     ),
     );
  }
}