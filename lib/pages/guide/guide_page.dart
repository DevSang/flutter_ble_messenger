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
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(ScreenUtil().setHeight(8)),
                                    topRight: Radius.circular(ScreenUtil().setHeight(8)),
                                )
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    Container(
                                        height: ScreenUtil().setHeight(35.5),
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(24),
                                        ),
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
                                        height: ScreenUtil().setHeight(23.5),
                                        margin: EdgeInsets.only(
                                            top: 8,
                                            bottom: 10,
                                        ),
                                        child: Text(
                                            '내 주변 사람들과 채팅 할 수 있는 공간',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w700,
                                                fontSize: ScreenUtil().setSp(16),
                                                color: Color.fromRGBO(43, 43, 43, 1),
                                                letterSpacing: ScreenUtil().setWidth(-0.8)
                                            ),
                                        )
                                    ),
                                    Container(
                                        child: Text(
                                            '위치 및 블루투스 권한이 필요합니다.',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: ScreenUtil().setSp(13),
                                                color: Color.fromRGBO(107, 107, 107, 1),
                                                letterSpacing: ScreenUtil().setWidth(-0.65)
                                            ),
                                        )
                                    ),
                                    Container(
                                        child: Text(
                                            'HWA 는 사용자의 위치를 추적하지 않아요 :)',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: ScreenUtil().setSp(13),
                                                color: Color.fromRGBO(107, 107, 107, 1),
                                                letterSpacing: ScreenUtil().setWidth(-0.65)
                                            ),
                                        )
                                    ),
                                    InkWell(
                                        child: Container(
                                            width: ScreenUtil().setWidth(319),
                                            height: ScreenUtil().setHeight(44),
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(27),
                                            ),
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(76, 96, 191, 1),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        ScreenUtil().setHeight(8)
                                                    )
                                                )
                                            ),
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    '단화 시작하기',
                                                    style: TextStyle(
                                                        fontFamily: "NotoSans",
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: ScreenUtil().setSp(16),
                                                        color: Color.fromRGBO(255, 255, 255, 1),
                                                        letterSpacing: ScreenUtil().setWidth(-0.8)
                                                    ),
                                                ),
                                            )
                                        ),
                                        onTap: () {
                                            Navigator.pushNamed(context, '/main');
                                        },
                                    ),
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