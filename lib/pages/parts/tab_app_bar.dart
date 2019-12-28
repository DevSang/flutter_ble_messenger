import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/signin_page.dart';
import 'package:Hwa/utility/get_same_size.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:kvsql/kvsql.dart';

class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String title;
    final Widget leftChild;
    final Widget rightChild;
    double sameSize;

    // 로그아웃 key/value 지우기 위함
    SharedPreferences prefs;
    final store = KvStore();

    @override
    final Size preferredSize;
    TabAppBar({@required this.title, this.leftChild, this.rightChild})
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
                    height: ScreenUtil().setHeight(64),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(16),
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
                                child: Row(
                                    children: <Widget>[
                                        Container(
                                            width: sameSize*38,
                                            height: sameSize*38,
                                            decoration: BoxDecoration(
                                                borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(19)),
                                                border: Border.all(
                                                    width: ScreenUtil().setWidth(1),
                                                    color: Color.fromRGBO(0, 0, 0, 0.05)
                                                )
                                            ),
                                            child: InkWell(
                                                child: ClipRRect(
                                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(19)),
                                                    child: Image.asset(
                                                        Constant.PROFILE_IMG,
                                                        width: ScreenUtil().setWidth(38),
                                                        height: ScreenUtil().setHeight(38),
                                                        fit: BoxFit.fill,
                                                    )
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
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: ScreenUtil().setWidth(12.5),
                                                    ),
                                                    child: Text(
                                                        title,
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight.w500,
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
                                child: rightChild
                            ),
                        ],
                    )
                )
            )
        );
    }
}