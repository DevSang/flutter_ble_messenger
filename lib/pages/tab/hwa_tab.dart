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
           body: Center (child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
               Image.asset('assets/images/logo.png'),

               ],
           ),
     ),
     );
  }


}


