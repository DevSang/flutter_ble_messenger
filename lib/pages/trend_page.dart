import 'package:flutter/material.dart';

class TrendPage extends StatefulWidget {
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("실시간 단화 트렌드", style: TextStyle(color: Colors.black),),
          actions: <Widget>[
      IconButton(
      icon: Image.asset('assets/images/icon/navIconSearch.png'),
      onPressed: null,
    )
    ]
      ),
    );
  }
}