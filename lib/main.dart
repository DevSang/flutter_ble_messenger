import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/pages/home_page.dart';
import 'package:Hwa/pages/signin_page.dart';
import 'data/local/SharedprefsHelper.dart';
import 'package:Hwa/pages/bottom_navigation.dart';

//void main() => runApp(MyApp());


Future main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SharedPrefsHelper().initialize();

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HWA',
      theme: ThemeData.light(),
      home: BottomNavigation(),
    );
  }
}




