import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/pages/home_page.dart';
import 'package:Hwa/pages/signin_page.dart';
import 'package:Hwa/bloc/injector.dart';
import 'data/local/SharedprefsHelper.dart';
import 'package:Hwa/pages/bottom_navigation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: BottomNavigation(),
    );
  }
}




//Future main() async {
//  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//  await SharedPrefsHelper().initialize();
//
//  runApp(new MyApp());
//}

//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Injector(
//      child: new MaterialApp(
//        title: 'HWA',
//        debugShowCheckedModeBanner: true,
//        theme: new ThemeData(
//          backgroundColor: Colors.white,
//          primarySwatch: Colors.blue,
//          scaffoldBackgroundColor: Colors.grey[100],
//          iconTheme: IconThemeData(color: Colors.blueGrey[700]),
//          primaryIconTheme: IconThemeData(color: Colors.blueGrey[700]),
//        ),
//        home: prefsHelper.isLogin ? HomePage() : SigninPage(),
//      ),
//    );
//  }
//}
