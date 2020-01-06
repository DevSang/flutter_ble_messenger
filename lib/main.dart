import 'package:Hwa/pages/profile/profile_page.dart';
import 'package:Hwa/pages/signin/signup_name.dart';
import 'package:Hwa/pages/signin/signup_page.dart';
import 'package:Hwa/pages/trend/trend_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/home.dart';
import 'package:Hwa/pages/signin/signin_page.dart';
import 'package:Hwa/pages/parts/common/bottom_navigation.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/chatting/notice_page.dart';
import 'package:Hwa/pages/chatting/notice_write_page.dart';
import 'package:Hwa/pages/chatting/notice_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:catcher/catcher_plugin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

//import 'package:kakao_flutter_sdk/auth.dart';


Future main() async {
//	KakaoContext.clientId = "a3676c7b7fcfdedf54043bb8618fcb80";
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//  SharedPreferences prefs = await SharedPreferences.getInstance();
//  bool isLogged = (prefs.getBool('isLogged') ?? false) ;

//  var home;
//  if(isLogged)
//    home = BottomNavigation();
//  else
//    home = SignInPage() ;

    CatcherOptions debugOptions = CatcherOptions(
        SilentReportMode(),
        [
            ConsoleHandler()
        ]
    );
    CatcherOptions releaseOptions = CatcherOptions(
        SilentReportMode(),
        [
            EmailManualHandler(["gjrjf@gmail.com"])
        ]
    );

//    Catcher(HereWeAreApp(), debugConfig: debugOptions, releaseConfig: releaseOptions);

//    runApp(new HereWeAreApp());
    runApp(EasyLocalization(child:HereWeAreApp()));
}

class HereWeAreApp extends StatelessWidget {

	@override
    Widget build(BuildContext context) {
	    SystemChrome.setPreferredOrientations([
	        DeviceOrientation.portraitUp,
	        DeviceOrientation.portraitDown,
	    ]);

	    var data = EasyLocalizationProvider.of(context).data;

	    return //MultiProvider(
//            providers: [
//
//            ],
            EasyLocalizationProvider(
				data: data,
	            child: MaterialApp(
		            title: 'HWA',
		            theme: ThemeData.light(),
		            home: HomePage(),
		            debugShowCheckedModeBanner: false,
		            initialRoute: '/',
		            routes: {
			            '/login': (context) => SignInPage(),                // login
			            '/register': (context) => SignUpPage(),             // register
			            '/register2': (context) => SignUpNamePage(),        // register name check
			            '/main': (context) => BottomNavigation(),           // main
			            '/profile': (context) => ProfilePage(),             // profile
			            '/trend': (context) => TrendPage(),                 // trend
			            '/chatroom': (context) => ChatroomPage(),
			            '/notice': (context) => NoticePage(),
			            '/notice_write': (context) => NoticeWritePage(),
			            '/notice_detail': (context) => NoticeDetailPage(),
		            },
		            localizationsDelegates: [
		                GlobalMaterialLocalizations.delegate,
		                GlobalWidgetsLocalizations.delegate,
		                EasylocaLizationDelegate(
				            locale: data.locale,
				            path: 'assets/langs'),
		            ],
                    supportedLocales: [Locale('en', 'US'), Locale('ko', 'KR')],
                    locale: data.locale,
	            ),
            );
//        );
    }
}
