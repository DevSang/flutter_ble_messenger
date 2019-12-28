import 'package:Hwa/pages/profile_page.dart';
import 'package:Hwa/pages/signup_name.dart';
import 'package:Hwa/pages/signup_page.dart';
import 'package:Hwa/pages/trend_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/app.dart';
import 'package:Hwa/pages/signin_page.dart';
import 'package:Hwa/pages/bottom_navigation.dart';
import 'package:Hwa/pages/chatroom_page.dart';
import 'package:Hwa/pages/notice_page.dart';
import 'package:Hwa/pages/notice_write_page.dart';
import 'package:Hwa/pages/notice_detail_page.dart';


Future main() async {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//  SharedPreferences prefs = await SharedPreferences.getInstance();
//  bool isLogged = (prefs.getBool('isLogged') ?? false) ;

//  var home;
//  if(isLogged)
//    home = BottomNavigation();
//  else
//    home = SignInPage() ;
    runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);
//    SystemChrome.setSystemUIOverlayStyle(
//        SystemUiOverlayStyle(
//        statusBarColor: Colors.white
//    ));

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white,
        )
    );
    return MaterialApp(
        title: 'HWA',
        theme: ThemeData.light(),
        home: MainPage(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
            '/login': (context) => SignInPage(),  // login
            '/register': (context) => SignUpPage(), //register
            '/register2': (context) => SignUpNamePage(), //register name check
            '/main': (context) => BottomNavigation(), // main
            '/profile': (context) => ProfilePage(), // profile
            '/trend': (context) => TrendPage(), // trend
            '/chatroom': (context) => ChatroomPage(),
            '/notice': (context) => NoticePage(),
            '/notice_write': (context) => NoticeWritePage(),
            '/notice_detail': (context) => NoticeDetailPage(),
        }
    );
  }
}




