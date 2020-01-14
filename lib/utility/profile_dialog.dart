import 'dart:io';
import 'dart:developer' as developer;
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/package/gauge/gauge_driver.dart';
import 'package:Hwa/pages/parts/chatting/full_photo.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/utility/action_sheet.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/gauge_animate.dart';
import 'package:Hwa/utility/inputStyle.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/utility/validate_nickname.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
    bool isLoading;
    bool showGauge;
    GaugeDriver gaugeDriver;

    @override
    void initState() {
        super.initState();

        keyboardUp = false;
        isLoading = false;
        showGauge = false;
        _nickNameEditingController.text = widget.nickName;
        _introEditingController.text = widget.intro ?? "";

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

        nickFocusNode.addListener(_listener);
        introFocusNode.addListener(_listener);

    }

    /*
     * @author : hs
     * @date : 2020-01-15
     * @description : focus에 따른 색상 변경
    */
    void _listener() {
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
     * @description : 닉네임 체크 후 저장
    */
    void checkNick(String nick, String myNick) async {

        if (await ValidateNickname().nickAllFactCheck(nick, myNick)) {
            print("saveProfile");
            saveProfile();
        }
    }

    // TODO: 명함 저장 추가
    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 프로필 변경사항 저장
    */
    void saveProfile() {
        setState(() {
            isLoading = true;
        });

        if (_nickNameEditingController.text != widget.nickName || _introEditingController.text != widget.intro) {
            // 닉네임, 소개글중 하나라도 바뀌었을 시
            Map<String, dynamic> saveProfileInfo = {
                'updateTs ' : new DateTime.now().microsecondsSinceEpoch,
                'nickname' :  _nickNameEditingController.text,
                'description' :  _introEditingController.text,
            };

            Provider.of<UserInfoProvider>(context, listen: false).setProfile(saveProfileInfo);
        }

        setState(() {
            isLoading = false;
        });

        popUp();
    }

    /*
	 * @author : hk
	 * @date : 2020-01-01
	 * @description : 프로필 사진 업로드
	 */
    void uploadImage(int flag) async {
        File imageFile;

        if(flag == 0 || flag == 1){
            // 사진첩 열기
            imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
        } else {
            // 카메라 열기
            imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
        }

        if(imageFile != null){
            setState(() {
                isLoading = true;
            });

            // 파일 업로드 API 호출
            Response response;

            if (flag == 0 || flag == 2) {

                // 프로필 사진 업로드
                response = await CallApi.fileUploadCall(url: "/api/v2/user/profile/image", filePath: imageFile.path, onSendProgress: (int sent, int total){

                    if (!showGauge) {
                        gaugeDriver = new GaugeDriver();
                        setState((){
                            isLoading = false;
                            showGauge = true;
                        });
                    }

                    gaugeDriver.drive(sent/total);

                    if (sent == total) {
                        setState((){
                            showGauge = false;
                            isLoading = true;
                        });
                    }
                });
            } else {
                // TODO: 명함 업로드
                // 명함 사진 업로드
                response = await CallApi.fileUploadCall(url: "/api/v2/user/businesscard", filePath: imageFile.path, onSendProgress: (int sent, int total){});
            }

            UserInfoProvider userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

            if(response.statusCode == 200){

                // 기존 이미지 있을 시 사용자 프로필 캐시 지우고 새로 로딩 (없을 시 새로 로딩만)
                if(userInfoProvider.profileURL != null) {
                    await userInfoProvider.changedProfileImg();
                }

                userInfoProvider.uploadAndCreateProfileCacheImg();

                setState((){
                    isLoading = false;
                });

            } else {
                developer.log("## 이미지파일 업로드에 실패하였습니다.");
            }
        }
    }

    @override
    Widget build(BuildContext context) {

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
        UserInfoProvider uip = Provider.of<UserInfoProvider>(context);
        Widget profileImageWidget = uip.getUserProfileImgNotDefault();        // Image Widget (CachedImage)
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
                                                            ActionSheetState().showActionSheet(
                                                                context: context, child: _buildActionSheet(true)
                                                            );
                                                        },
                                                    )
                                                ),

                                                // 프로필 이미지 있으면 표현
                                                profileImageWidget != null
                                                    ? Container(
                                                        width: ScreenUtil().setWidth(281),
                                                        height: ScreenUtil().setHeight(281),
                                                        child: InkWell(
                                                            child: ClipRRect(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(ScreenUtil().setWidth(10)),
                                                                    topRight: Radius.circular(ScreenUtil().setWidth(10)),
                                                                ),
                                                                child: profileImageWidget
                                                            ),
                                                            onTap: () {
                                                                Navigator.push(
                                                                    context, MaterialPageRoute(
                                                                    builder: (context) => FullPhoto(photoUrl: Provider.of<UserInfoProvider>(context).profileURL))
                                                                );
                                                            },
                                                        )
                                                    )
                                                    : Container(),

                                                Positioned(
                                                    right: ScreenUtil().setWidth(16),
                                                    top: ScreenUtil().setHeight(20),
                                                    child: Column(
                                                        children: <Widget>[
                                                            InkWell(
                                                                child: Container(
                                                                    margin: EdgeInsets.only(
                                                                        bottom: ScreenUtil().setHeight(14.5),
                                                                    ),
                                                                    child: designTopBtn('assets/images/icon/iconAttachCameraChat.png')
                                                                ),
                                                                onTap: () {
                                                                    ActionSheetState().showActionSheet(
                                                                        context: context, child: _buildActionSheet(true)
                                                                    );
                                                                },
                                                            ),
                                                            InkWell(
                                                                child: Container(
                                                                    child: designTopBtn('assets/images/icon/iconAttachCard.png')
                                                                ),
                                                                onTap: () {
                                                                    ActionSheetState().showActionSheet(
                                                                        context: context, child: _buildActionSheet(false)
                                                                    );
                                                                },
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
                                                showGauge
                                                    ? Positioned.fill(
                                                        child: Align(
                                                            alignment: Alignment.center,
                                                            child: GaugeAnimate(driver: gaugeDriver)
                                                        )
                                                    )
                                                    : Container()
                                                ,
                                                isLoading
                                                    ? Positioned.fill(
                                                        child: Align(
                                                            alignment: Alignment.center,
                                                            child: const CircularProgressIndicator(
                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                    Color.fromRGBO(76, 96, 191, 1),
                                                                )
                                                            )
                                                        )
                                                    )
                                                    : Container()
                                            ],
                                        ),
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
                                            designBottomBtn(widget.leftButtonText, true),

                                            designBottomBtn(widget.rightButtonText, false),
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
        return Container(
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
        );
    }

    Widget designBottomBtn(String btnText, bool isCancel) {
        return InkWell(
            child:
            Container(
                width: ScreenUtil().setWidth(125),
                height: ScreenUtil().setHeight(36),
                margin: EdgeInsets.only(
                    right: isCancel ? ScreenUtil().setWidth(5) : 0,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(8))
                    ),
                    color: isCancel ? Color.fromRGBO(235, 235, 235, 1) : Color.fromRGBO(76, 96, 191, 1),
                ),
                child: Center (
                    child: Text(
                        btnText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(13),
                            color: isCancel ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(255, 255, 255, 1),
                            letterSpacing: ScreenUtil().setWidth(-0.32),
                        ),
                    ),
                ),
            ),
            onTap: () {
                isCancel
                    ? popUp()
                    : checkNick(
                        _nickNameEditingController.text,
                        Provider.of<UserInfoProvider>(context, listen: false).nickname
                    );
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
                                Future.delayed(Duration(milliseconds: 50), () {
                                    _nickNameEditingController.clear();
                                });

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
                    hintText: "소개글을 입력해주세요.",
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

    Widget _buildActionSheet(bool regProfile) {
        return CupertinoActionSheet(
            title: Text(
                regProfile ?  "프로필 이미지" : "명함",
                style: TextStyle(
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.w500,
                    fontSize: ScreenUtil().setSp(16),
                ),
            ),
            actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text("앨범"),
                    onPressed: () {
                        regProfile ? uploadImage(0) : uploadImage(1);
                        Navigator.pop(context);
                    },
                ),
                CupertinoActionSheetAction(
                    child: Text("카메라"),
                    onPressed: () {
                        regProfile ? uploadImage(2) : uploadImage(3);
                        Navigator.pop(context);
                    },
                )
            ],
            cancelButton: CupertinoActionSheetAction(
                child: Text("취소"),
                onPressed: () {
                    Navigator.pop(context);
                },
            ),
        );
    }
}
