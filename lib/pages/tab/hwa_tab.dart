import 'package:flutter/material.dart';

class HwaTab extends StatefulWidget {
  @override
  _HwaTabState createState() => _HwaTabState();
}


class _HwaTabState extends State<HwaTab> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text("단화 목록"),
       )

);
  }
}