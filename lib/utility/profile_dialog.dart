import 'package:Hwa/utility/red_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-14
 * @description : Profile Edit Dialog PopUp
 */
class ProfileDialog extends StatefulWidget {
    final String nickName, intro, leftButtonText, rightButtonText;
    final int profileImgIdx, bCImgIdx;
    final Function func;

    ProfileDialog({
        @required this.nickName,
        @required this.intro,
        @required this.leftButtonText,
        @required this.rightButtonText,
        this.profileImgIdx,
        this.bCImgIdx,
        this.func,
    });

    ProfileDialogState createState() => ProfileDialogState();
}

class ProfileDialogState extends State<ProfileDialog> {
    TextEditingController _nickNameEditingController = TextEditingController();
    TextEditingController _introEditingController = TextEditingController();

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        _nickNameEditingController.text = widget.nickName;
        _introEditingController.text = widget.intro ?? "";

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
                                Positioned(
                                    right: ScreenUtil().setWidth(16),
                                    bottom: ScreenUtil().setHeight(18),
                                    child: Container(
                                        width: ScreenUtil().setWidth(87),
                                        height: ScreenUtil().setWidth(48),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                                Container(
                                                    width: ScreenUtil().setWidth(17),
                                                    height: ScreenUtil().setWidth(13),
                                                    child: Image.asset(
                                                        'assets/images/icon/cardProfileset.png',
                                                        fit: BoxFit.cover,
                                                    )
                                                ),
                                                Container(
                                                    child: Text(
                                                        '명함 등록'
                                                    )
                                                ),
                                            ],
                                        )
///                                        assets/images/icon/personIconProfileset.png
///                                        assets/images/icon/cardProfileset.png
                                    ),
                                ),
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
