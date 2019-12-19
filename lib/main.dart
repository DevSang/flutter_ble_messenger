import 'package:Hwa/pages/profile_page.dart';
import 'package:Hwa/pages/signup_name.dart';
import 'package:Hwa/pages/signup_page.dart';
import 'package:Hwa/pages/trend_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/app.dart';
import 'package:Hwa/pages/signin_page.dart';
import 'package:Hwa/pages/bottom_navigation.dart';

Future main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HWA',
      theme: ThemeData.light(),
      home: MainPage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/login': (context) => SignInPage(),
        '/register': (context) => SignUpPage(),
        '/register2': (context) => SignUpNamePage(),
        '/main': (context) => BottomNavigation(),
        '/profile': (context) => ProfilePage(),
        '/trend': (context) => TrendPage(),
    }
    );
  }
}




