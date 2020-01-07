import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:catcher/catcher_plugin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:Hwa/home.dart';
import 'package:Hwa/pages/profile/profile_page.dart';
import 'package:Hwa/pages/signin/signup_name.dart';
import 'package:Hwa/pages/signin/signup_page.dart';
import 'package:Hwa/pages/trend/trend_page.dart';
import 'package:Hwa/pages/signin/signin_page.dart';
import 'package:Hwa/pages/parts/common/bottom_navigation.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/chatting/notice_page.dart';
import 'package:Hwa/pages/chatting/notice_write_page.dart';
import 'package:Hwa/pages/chatting/notice_detail_page.dart';

import 'package:Hwa/data/state/friend_count.dart';
import 'package:Hwa/data/state/user_info.dart';

//import 'package:kakao_flutter_sdk/auth.dart';


Future main() async {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    CatcherOptions debugOptions = CatcherOptions(
        DialogReportMode (),
        [ConsoleHandler()]
    );

    CatcherOptions releaseOptions = CatcherOptions(
        SilentReportMode(),
        [EmailManualHandler(["gjrjf@gmail.com"])]
    );


//    Catcher(EasyLocalization(child:HereWeAreApp()), debugConfig: debugOptions, releaseConfig: releaseOptions);
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

	    return MultiProvider(
            providers: [
	            ChangeNotifierProvider(create: (_) => FriendCount()),
	            ChangeNotifierProvider(create: (_) => UserInfo())
            ],
            child: EasyLocalizationProvider(
				data: data,
	            child: MaterialApp(
		            title: 'HWA',
		            theme: ThemeData.light(),
		            home: HomePage(),
                    navigatorKey: Catcher.navigatorKey,
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
            )
        );
    }
}
