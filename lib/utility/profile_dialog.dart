import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/utility/inputStyle.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/utility/validate_nickname.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';


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

class ProfileDialogState extends State<ProfileDialog> with TickerProviderStateMixin {
    TextEditingController _nickNameEditingController = TextEditingController();
    TextEditingController _introEditingController = TextEditingController();
    FocusNode nickFocusNode = new FocusNode();
    FocusNode introFocusNode = new FocusNode();
    bool keyboardUp;

    @override
    void initState() {
        super.initState();
        keyboardUp = false;

        KeyboardVisibilityNotification().addNewListener(
            onChange: (bool visible) {
                if(visible) {
                    keyboardUp = true;
                } else {
                    keyboardUp = false;
                }
                setState(() { });
            }
        );

    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 키보드 오픈 여부에 따른 프로필 이미지 영역 처리
    */
    void _listener(FocusNode focusNode) {
        if (focusNode.hasFocus) keyboardUp = true;
        else keyboardUp = false;

        setState(() {});
    }

    /*
     * @project : HWA - Mobile
     * @author : hs
     * @date : 2020-01-14
     * @description : Popup function
     */
    void popUp() {
        Navigator.of(context).pop();
    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 닉네임 체크
    */
    void checkNick(String nick, Function fn) async {
        ValidateNickname vn = new ValidateNickname();

        if (await vn.nickAllFactCheck(nick)) {
            fn();
        }
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
        Widget profileImageWidget = Provider.of<UserInfoProvider>(context).getUserProfileImgNotDefault();
        Widget bcImageWidget; // TODO: 명함 받아오기
        bool existBC = true; // TODO: 임시 Boolean

        return
            AnimatedSize(
                curve: Curves.ease,
                vsync: this,
                duration: new Duration(milliseconds: 500),
                child: Container(
                    width: ScreenUtil().setWidth(281),
                    height: keyboardUp ? ScreenUtil().setHeight(198) : ScreenUtil().setHeight(479),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                            children: <Widget>[
                                AnimatedOpacity(
                                    opacity: keyboardUp ? 0 : 1,
                                    duration: Duration(milliseconds: 500),
                                    child: Container(
                                        width: ScreenUtil().setWidth(281),
                                        height: keyboardUp ? 0 : ScreenUtil().setHeight(281),
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(245, 245, 245, 1),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(ScreenUtil().setWidth(10)),
                                                topRight: Radius.circular(ScreenUtil().setWidth(10)),
                                            ),
                                        ),
                                        child: Stack(
                                            children: <Widget>[
                                                Visibility(
                                                    visible: profileImageWidget == null ? true : false,
                                                    child: InkWell(
                                                        child: Align(
                                                            alignment: Alignment.center,
                                                            child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: <Widget>[
                                                                    Container(
                                                                        width: ScreenUtil().setWidth(29),
                                                                        height: ScreenUtil().setWidth(32.2),
                                                                        margin: EdgeInsets.only(
                                                                            bottom: ScreenUtil().setHeight(5.6),
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                            image: DecorationImage(
                                                                                image: AssetImage(
                                                                                    'assets/images/icon/personIconProfileset.png',
                                                                                ),
                                                                                fit: BoxFit.cover
                                                                            )
                                                                        ),
                                                                    ),
                                                                    Text(
                                                                        '프로필 이미지 등록',
                                                                        style: TextStyle(
                                                                            fontFamily: "NotoSans",
                                                                            fontWeight: FontWeight.w500,
                                                                            letterSpacing: ScreenUtil().setWidth(-0.65),
                                                                            fontSize: ScreenUtil().setSp(13),
                                                                            color: Color.fromRGBO(107, 107, 107, 1)
                                                                        )
                                                                    )
                                                                ],
                                                            )
                                                        ),
                                                        onTap: () {
                                                        },
                                                    )
                                                ),

                                                // 프로필 이미지 있으면 표현
                                                profileImageWidget ?? Container(),

                                                Positioned(
                                                    right: ScreenUtil().setWidth(16),
                                                    top: ScreenUtil().setHeight(20),
                                                    child: Column(
                                                        children: <Widget>[
                                                            Container(
                                                                margin: EdgeInsets.only(
                                                                    bottom: ScreenUtil().setHeight(14.5),
                                                                ),
                                                                child: designTopBtn('assets/images/icon/iconAttachCameraChat.png')
                                                            ),

                                                            Container(
                                                                child: designTopBtn('assets/images/icon/iconAttachCard.png')
                                                            )
                                                        ],
                                                    ),
                                                ),

                                                Positioned(
                                                    right: ScreenUtil().setWidth(16),
                                                    bottom: ScreenUtil().setHeight(18),
                                                    child: Container(
                                                        width: ScreenUtil().setWidth(87),
                                                        height: ScreenUtil().setWidth(48),
                                                        color: Color.fromRGBO(255, 255, 255, 1),
                                                        child: existBC
                                                            ? Column(
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
                                                                    margin: EdgeInsets.only(
                                                                        top: ScreenUtil().setHeight(2),
                                                                    ),
                                                                    child: Text(
                                                                        '명함 등록',
                                                                        style: TextStyle(
                                                                            fontFamily: "NotoSans",
                                                                            fontWeight: FontWeight.w500,
                                                                            letterSpacing: ScreenUtil().setWidth(-0.65),
                                                                            fontSize: ScreenUtil().setSp(13),
                                                                            color: Color.fromRGBO(107, 107, 107, 1)
                                                                        )
                                                                    )
                                                                ),
                                                            ],
                                                        )
                                                            : Container()   // TODO: 명함 이미지
                                                    ),
                                                ),
                                            ],
                                        )
                                    ),
                                ),
                                // 닉네임, 소개
                                Container(
                                    width: ScreenUtil().setWidth(281),
                                    height: ScreenUtil().setHeight(129),
                                    child: Column(
                                        children: <Widget>[
                                            buildNickTextField(),
                                            buildIntroTextField()
                                        ],
                                    )
                                ),

                                // 하단 버튼
                                Container(
                                    width: ScreenUtil().setWidth(281),
                                    height: ScreenUtil().setHeight(69),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                                color: Color.fromRGBO(39, 39, 39, 0.15),
                                                width: ScreenUtil().setHeight(1)
                                            )
                                        ),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            designBottomBtn(widget.leftButtonText, true, popUp),

                                            designBottomBtn(widget.rightButtonText, false, widget.func),
                                        ],
                                    ),
                                ),
                            ],
                        )
                    )
                )// 프로필 이미지
            );
    }

    Widget designTopBtn(String imgUrl) {
        return GestureDetector(
            child: Container(
                width: ScreenUtil().setWidth(32),
                height: ScreenUtil().setWidth(32),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    image: DecorationImage(
                        image:AssetImage(imgUrl)
                    ),
                    boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.16),
                            blurRadius: ScreenUtil().setWidth(3), // has the effect of softening the shadow
                            spreadRadius: ScreenUtil().setWidth(0),
                            offset: new Offset(0, ScreenUtil().setWidth(1.5))
                        )
                    ],
                    shape: BoxShape.circle
                )
            ),
            onTap:(){
            }
        );
    }

    Widget designBottomBtn(String btnText, bool isLeft, Function fn) {
        return InkWell(
            child:
            Container(
                width: ScreenUtil().setWidth(125),
                height: ScreenUtil().setHeight(36),
                margin: EdgeInsets.only(
                    right: isLeft ? ScreenUtil().setWidth(5) : 0,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(8))
                    ),
                    color: isLeft ? Color.fromRGBO(235, 235, 235, 1) : Color.fromRGBO(76, 96, 191, 1),
                ),
                child: Center (
                    child: Text(
                        btnText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(13),
                            color: isLeft ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(255, 255, 255, 1),
                            letterSpacing: ScreenUtil().setWidth(-0.32),
                        ),
                    ),
                ),
            ),
            onTap: () {
                checkNick(_nickNameEditingController.text, fn);
            },
        );
    }

    Widget buildNickTextField() {
        return Container(
            width: ScreenUtil().setWidth(255),
            height: ScreenUtil().setHeight(38.5),
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(20),
                bottom: ScreenUtil().setHeight(12),
            ),
            child: TextFormField(
                focusNode: nickFocusNode,
                maxLength: 8,
                controller: _nickNameEditingController,
                style: TextStyle(
                    color: Color.fromRGBO(39, 39, 39, 1),
                    fontSize: ScreenUtil().setSp(16),
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: ScreenUtil().setWidth(-0.8),
                ),
                decoration:  InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(15),
                    ),
                    suffixIcon:
                    Container(
                        width: ScreenUtil().setWidth(15),
                        height: ScreenUtil().setHeight(15),
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(5),
                            top: ScreenUtil().setWidth(5),
                            bottom: ScreenUtil().setWidth(5),
                        ),
                        child: IconButton(
                            icon: nickFocusNode.hasFocus
                                ? Image.asset("assets/images/icon/iconDeleteSmall.png")
                                : Image.asset("assets/images/icon/editIcon.png"),
                            onPressed: () {
                                if (nickFocusNode.hasFocus) {
                                    nickFocusNode.requestFocus();
                                } else {
                                    Future.delayed(Duration(milliseconds: 50), () {
                                        _nickNameEditingController.clear();
                                    });
                                }

                            },
                        )
                    ),
                    counterText: "",
                    hintStyle: InputStyle().inputHintText,
                    hintText: widget.nickName,
                    enabledBorder:  InputStyle().getEnableBorder,
                    focusedBorder: InputStyle().getFocusBorder,
                    fillColor: InputStyle().getBackgroundColor(nickFocusNode),
                    filled: true,
                ),
            )
        );
    }

    Widget buildIntroTextField() {
        return Container(
            width: ScreenUtil().setWidth(255),
            height: ScreenUtil().setHeight(38.5),
            child: TextFormField(
                focusNode: introFocusNode,
                maxLength: 17,
                controller: _introEditingController,
                obscureText: true,
                style: introTextStyle(false),
                decoration:  InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(15),
                    ),
                    suffixIcon:
                    Container(
                        width: ScreenUtil().setWidth(15),
                        height: ScreenUtil().setHeight(15),
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(5),
                            top: ScreenUtil().setWidth(5),
                            bottom: ScreenUtil().setWidth(5),
                        ),
                        child: Visibility(
                            visible: widget.intro != null,
                            child: IconButton(
                                icon: introFocusNode.hasFocus
                                    ? Image.asset("assets/images/icon/iconDeleteSmall.png")
                                    : Image.asset("assets/images/icon/editIcon.png"),
                                onPressed: () {
                                    if (introFocusNode.hasFocus) {
                                        introFocusNode.requestFocus();
                                    } else {
                                        Future.delayed(Duration(milliseconds: 50), () {
                                            _introEditingController.clear();
                                        });
                                    }
                                },
                            )
                        )

                    ),
                    counterText: "",
                    enabledBorder:  InputStyle().getEnableBorder,
                    focusedBorder: InputStyle().getFocusBorder,
                    fillColor: InputStyle().getBackgroundColor(introFocusNode),
                    filled: true,
                    hintText: widget.intro ?? "안녕하세요 :) " + Provider.of<UserInfoProvider>(context).nickname + "입니다. ",
                    hintStyle: introTextStyle(true),
                ),
            )
        );
    }

    TextStyle introTextStyle(bool hintText) {
        return TextStyle(
            color: hintText ? Color.fromRGBO(39, 39, 39, 0.4) : Color.fromRGBO(107, 107, 107, 1),
            fontSize: ScreenUtil().setSp(15),
            fontFamily: 'NotoSans',
            fontWeight: FontWeight.w500,
            letterSpacing: ScreenUtil().setWidth(-0.38),
        );
    }
}