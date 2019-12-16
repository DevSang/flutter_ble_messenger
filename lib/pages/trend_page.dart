import 'package:flutter/material.dart';

class TrendPage extends StatefulWidget {
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("실시간 단화 트렌드",
            style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'NotoSans'),
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          actions: <Widget>[
      IconButton(
      icon: Image.asset('assets/images/icon/navIconSearch.png'),
        padding: EdgeInsets.only(right: 16),
        onPressed: null,
    )
    ]
      ),
    );
  }
}