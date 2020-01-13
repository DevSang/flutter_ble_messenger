import 'package:Hwa/utility/red_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomProfileDialog extends StatelessWidget {
    final String nickName, intro, leftButtonText, rightButtonText, hintText;
    final int profileImgIdx, bCImgIdx;
    final Function func;
    TextEditingController _nickNameEditingController = TextEditingController();
    TextEditingController _introEditingController = TextEditingController();

    CustomProfileDialog({
        @required this.nickName,
        @required this.intro,
        @required this.leftButtonText,
        @required this.rightButtonText,
        this.hintText,
        this.profileImgIdx,
        this.bCImgIdx,
        this.func,
    });

    @override
    Widget build(BuildContext context) {
        _nickNameEditingController.text = nickName;
        _introEditingController.text = intro ?? "";

        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    ScreenUtil().setWidth(10)
                ),
            ),
            elevation: 10,
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            child: dialogContent(context),
        );
    }

    dialogContent(BuildContext context) {
        return Container(
            width: ScreenUtil().setWidth(281),
            height: ScreenUtil().setHeight(479),
            child: Column(
                children: <Widget>[
                    // 프로필 이미지
                    Container(
                        width: ScreenUtil().setWidth(281),
                        height: ScreenUtil().setHeight(281),
                        child: Stack(
                            children: <Widget>[
                                Positioned(
                                    child: Column(
                                        children: <Widget>[
                                            Container(

                                            ),
                                            Container(),
                                        ],
                                    ),
                                ),
                                Positioned(),
                            ],
                        )
                    ),

                    // 닉네임, 소개
                    Container(),

                    // 하단 버튼
                    Container(),
                ],
            )
        );
    }

}
