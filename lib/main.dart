import 'dart:async';
import 'dart:developer' as developer;
import 'package:Hwa/pages/guide/guide_page.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbar_text_color/flutter_statusbar_text_color.dart';
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
import 'package:Hwa/pages/policy/opensource_policy.dart';
import 'package:Hwa/pages/policy/service_policy.dart';

import 'package:Hwa/data/state/friend_count.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/data/state/friend_request_list_info_provider.dart';
import 'package:Hwa/data/state/friend_list_info_provider.dart';
import 'package:Hwa/data/state/chat_notice_item_provider.dart';
import 'package:Hwa/data/state/chat_notice_reply_provider.dart';

import 'package:Hwa/data/models/friend_request_info.dart';
import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/data/models/chat_notice_item.dart';
import 'package:Hwa/data/models/chat_notice_reply.dart';
//import 'package:kakao_flutter_sdk/auth.dart';

Future main() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    ));
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
// ios 13 dark status bar
class StatusBarTextRouteObserver extends NavigatorObserver {
    Timer _timer;

    _setStatusBarTextColor() {
        _timer?.cancel();

        _timer = Timer(Duration(milliseconds: 200), () async {
            try {
                await FlutterStatusbarTextColor.setTextColor(
                    FlutterStatusbarTextColor.dark);
            } catch (_) {
                developer.log('set status bar text color failed');
            }
        });
    }

    @override
    void didPush(Route route, Route previousRoute) {
        super.didPush(route, previousRoute);
        _setStatusBarTextColor();
    }

    @override
    void didPop(Route route, Route previousRoute) {
        super.didPop(route, previousRoute);
        _setStatusBarTextColor();
    }
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
	            ChangeNotifierProvider(create: (_) => UserInfoProvider()),
	            ChangeNotifierProvider(create: (_) => FriendListInfoProvider(friendList: List<FriendInfo>())),
	            ChangeNotifierProvider(create: (_) => FriendRequestListInfoProvider(friendRequestList: List<FriendRequestInfo>())),
	            ChangeNotifierProvider(create: (_) => ChatRoomNoticeInfoProvider(chatNoticeList: List<ChatNoticeItem>())),
	            ChangeNotifierProvider(create: (_) => ChatRoomNoticeReplyProvider(noticeReplyList: List<ChatNoticeReply>())),
            ],
            child: EasyLocalizationProvider(
                data: data,
                child:MaterialApp(
                    title: 'HWA',
                    navigatorObservers: [StatusBarTextRouteObserver()],
                    supportedLocales: [Locale('en'), Locale('ko')],
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
                        '/opensource': (context) => OpenSourcePage(),
                        '/service_policy': (context) => ServicePolicyPage(),
                        '/guide': (context) => GuidePage(),
                        '/friends': (context) => FriendTab(),
                    },
                    localizationsDelegates: [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        EasylocaLizationDelegate(
                            locale: data.locale,
                            path: 'assets/langs',
                            useOnlyLangCode: true
                        ),
                    ],
                    locale: data.locale,
                    builder: (context, navigator) {
                        var lang = Localizations.localeOf(context).languageCode;

                        return Theme(
                            data: ThemeData(
                                fontFamily: lang == 'ko' ? "NotoSans" : "Manrope",
                            ),
                            child: navigator,
                        );
                    },
                ),
            )
        );
    }
}
