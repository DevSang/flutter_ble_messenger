import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ㅎㅇ"),
      ),
      body: Text("Body"),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Text("this is bottom"),
      ),
    );
  }
}