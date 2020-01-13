import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-13
 * @description : 회원가입 후 가이드 화면
 */
class GuidePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
                children: <Widget>[
                    Image(
                        image: AssetImage(
                            'assets/images/tutorialImg.png',
                        ),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: ScreenUtil().setHeight(236.5),
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(22),
                                bottom: ScreenUtil().setHeight(28),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(ScreenUtil().setHeight(8)),
                                    topRight: Radius.circular(ScreenUtil().setHeight(8)),
                                )
                            ),
                            child: Column(
                                children: <Widget>[
                                    Container(
                                        child: Text(
                                            '단화방 이란?',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w700,
                                                fontSize: ScreenUtil().setSp(24),
                                                color: Color.fromRGBO(43, 43, 43, 1),
                                            ),
                                        )
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                            bottom: 8,
                                        ),
                                        child: Text(
                                            '내 주변 사람들과 채팅 할 수 있는 공간',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w700,
                                                fontSize: ScreenUtil().setSp(24),
                                                color: Color.fromRGBO(43, 43, 43, 1),
                                            ),
                                        )
                                    ),
                                    Container(),
                                    Container(),
                                    Container(),
                                ],
                            )
                        )
                    )
                ],
            )
        ),
    );
  }

}