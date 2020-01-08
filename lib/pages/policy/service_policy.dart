import 'package:flutter/material.dart';

class ServicePolicyPage extends StatefulWidget {
  @override
  _ServicePolicyPageState createState() => _ServicePolicyPageState();
}

class _ServicePolicyPageState extends State<ServicePolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0.0,
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          centerTitle: true,
          title: Text("서비스 정책", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans',fontWeight: FontWeight.w600),
          ),
        )
    );
  }
}


