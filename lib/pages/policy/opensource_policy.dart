import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:expandable/expandable.dart';
import 'opensource_license.dart';

class OpenSourcePage extends StatefulWidget {
  @override
  _OpenSourcePageState createState() => _OpenSourcePageState();
}

class _OpenSourcePageState extends State<OpenSourcePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        iconTheme: IconThemeData(
          color: Color.fromRGBO(77, 96, 191, 1), //change your color here
        ),
        title: Text('오픈소스 라이선스',
          style: TextStyle(
              fontFamily: "NotoSans",
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(39, 39, 39, 1),
              fontSize: ScreenUtil().setSp(16)
          ),
        ),
        leading:  IconButton(
            icon:  Image.asset('assets/images/icon/navIconPrev.png'),
              onPressed: () => Navigator.of(context).pop(null),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        brightness: Brightness.light),
          body: ExpandableTheme(
            data: ExpandableThemeData(iconColor: Colors.blue, useInkWell: false),
            child: ListView(
              children: <Widget>[
                EasyLocalization(),
                Intl(),
                ConfigurableExpansionTile(),
                TimeAgo(),
                LazyLoadScrollView(),
                StickyHeaders(),
                FlutterScreenutil(),
                Catcher(),
                JsonAnnotation(),
                Dio(),
                Http(),
                CachedNetworkImage(),
                FirebaseMessaging(),
                WebSocketChannel(),
                GeoLocator(),
                ImagePicker(),
                PhotoView(),
                SharedPreferences(),
                Provider(),
                Kvsql(),
                Sqlcool(),
                FlutterFacebookLogin(),
                GoogleSignIn(),
                FlutterKakaoLogin(),
                KakaoFlutterSdk(),
                AlphabetListScrollView(),
                FlutterSlidable(),
                ExpandableLibrary(),
                FlutterToast(),
                Emojis()
              ],
            ),
          ),
      );
    }
  }


