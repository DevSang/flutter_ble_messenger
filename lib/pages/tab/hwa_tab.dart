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
         backgroundColor: Colors.white,
         title: Text("단화방", style: TextStyle(color: Colors.black),),
         actions: <Widget>[
           IconButton(
             icon: Image.asset('assets/images/icon/navIconHot.png'),
             onPressed: null,
           ),
           IconButton(
             icon: Image.asset('assets/images/icon/navIconNew.png'),
             onPressed: null,
           )
         ],
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


