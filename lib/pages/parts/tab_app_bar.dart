import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/signin_page.dart';
import 'package:Hwa/utility/get_same_size.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:kvsql/kvsql.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-30
 * @description : Custom App Bar
 */
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String title;
    final Widget leftChild;
    double sameSize;

    // 로그아웃 key/value 지우기 위함
    SharedPreferences prefs;
    final store = KvStore();

    @override
    final Size preferredSize;
    TabAppBar({@required this.title, this.leftChild})
        : preferredSize = Size(375, 84);

    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 임시 로그아웃
    */
    Future<void> logOut() async {
        prefs = await SharedPreferences.getInstance();
        await store.onReady;
        prefs.remove('token');
        store.delete("friendList");
        store.delete("test");

        return;
    }

    Widget build(BuildContext context) {
        sameSize  = GetSameSize().main();

        return PreferredSize(
            preferredSize: preferredSize,
            child: SafeArea(
                child: Container(
                    width: ScreenUtil().setWidth(375),
                    height: ScreenUtil().setHeight(61.5),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(16),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                            new BoxShadow(
                                color: Color.fromRGBO(178, 178, 178, 0.8),
                                offset: new Offset(ScreenUtil().setWidth(0), ScreenUtil().setWidth(0.5)),
                                blurRadius: ScreenUtil().setWidth(0)
                            )
                        ]
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            Container(
                                height: ScreenUtil().setHeight(56.5),
                                child: Row(
                                    children: <Widget>[
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                                Container(
                                                    child: Text(
                                                        title,
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: ScreenUtil(allowFontScaling: true).setSp(20),
                                                            color: Color.fromRGBO(39, 39, 39, 1),
                                                            letterSpacing: ScreenUtil().setWidth(-0.5),
                                                        ),
                                                    ),
                                                ),
                                                leftChild
                                            ],
                                        ),
                                    ],
                                )
                            ),
                            Container(
                                width: ScreenUtil().setHeight(60.5),
                                height: ScreenUtil().setHeight(56.5),
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(8),
                                    right: ScreenUtil().setWidth(8),
                                    top: ScreenUtil().setHeight(8),
                                    bottom: ScreenUtil().setHeight(8.5),
                                ),
                                margin: EdgeInsets.only(
                                    right: ScreenUtil().setWidth(7.5),
                                ),
                                child: InkWell(
                                    child: Stack(
                                        children: <Widget>[
                                            Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                    width: ScreenUtil().setHeight(38),
                                                    height: ScreenUtil().setHeight(38),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:AssetImage(Constant.PROFILE_IMG),
                                                            fit: BoxFit.cover
                                                        ),
                                                        shape: BoxShape.circle
                                                    )
                                                ),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                left: 0,
                                                child: GestureDetector(
                                                    child: Container(
                                                        width: ScreenUtil().setHeight(21.5),
                                                        height: ScreenUtil().setHeight(21.5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            image: DecorationImage(
                                                                image:AssetImage("assets/images/icon/setIcon.png"),
                                                                fit: BoxFit.cover
                                                            ),
                                                            shape: BoxShape.circle,
                                                        )
                                                    )
                                                )
                                            ),
                                        ],
                                    ),
                                    onTap: () {
                                        logOut().then((value) {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {
                                                    return SignInPage();
                                                })
                                            );
                                        });
                                    },
                                )
                            ),
                        ],
                    )
                )
            )
        );
    }
}