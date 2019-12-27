import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import 'package:Hwa/constant.dart';

class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String title;
    final Widget child;

    @override
    final Size preferredSize;
    TabAppBar({@required this.title,
        @required this.child})
        : preferredSize = Size(375, 84);

    Widget build(BuildContext context) {
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white,
            )
        );

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
                                            width: ScreenUtil().setWidth(38),
                                            height: ScreenUtil().setWidth(38),
                                            decoration: BoxDecoration(
                                                borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(19)),
                                                border: Border.all(
                                                    width: ScreenUtil().setWidth(1),
                                                    color: Color.fromRGBO(0, 0, 0, 0.05)
                                                )
                                            ),
                                            child: Image.asset(
                                                Constant.PROFILE_IMG,
                                                width: ScreenUtil().setWidth(38),
                                                height: ScreenUtil().setWidth(38),
                                                fit: BoxFit.fill,
                                            )
                                        ),
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
                                        )
                                    ],
                                )
                            ),
                            Container(
                                child: child
                            ),
                        ],
                    )
                )
            )
        );
    }
}