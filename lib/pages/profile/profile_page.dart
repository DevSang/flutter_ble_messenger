import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:Hwa/pages/parts/chatting/full_photo.dart';
import 'package:Hwa/utility/validate_nickname.dart';
import 'package:dio/dio.dart';

import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/custom_switch.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/profile_dialog.dart';
import 'package:Hwa/pages/signin/signin_page.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/utility/validators.dart';
import 'package:Hwa/utility/emojis/emojis.dart';
import 'package:Hwa/utility/validate_nickname.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-14
 * @description : Profile Setting Page
 */
class ProfilePage extends StatefulWidget {
    @override
    _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State <ProfilePage>{
    PackageInfo packageInfo;

    SharedPreferences SPF;
    final store = KvStore();

    bool isSwitched = true;
    double sameSize = GetSameSize().main();
    bool allowedPush;
    bool allowedFriend;
    bool isLoading;
    String appVersion = "Beta";

    @override
    void initState() {
        _initState();
        isLoading = false;
        getSettingInfo();
	    super.initState();
    }

    void _initState() async {
        packageInfo = await PackageInfo.fromPlatform();
        appVersion = appVersion + " " + packageInfo.version ?? "";
    }

  /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 로그아웃
    */
    Future<void> logOut() async {
        SPF = await Constant.getSPF();
        await store.onReady;
        await SPF.remove('token');
        await SPF.remove('userInfo');
        await store.delete("friendList");
        await store.delete("test");

        Navigator.of(context).pushAndRemoveUntil(
	        MaterialPageRoute(builder: (BuildContext context) => SignInPage()),
	        ModalRoute.withName('/login')
        );

        return;
    }

    /*
     * @author : hs
     * @date : 2020-01-01
     * @description : 프로필 설정 받아오기
    */
    void getSettingInfo() async {
        try {
            /// 참여 타입 수정
            String uri = "/api/v2/user/profile?target_user_idx=" +  Constant.USER_IDX.toString();
            print(uri);
            final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);
            print(response.body);
            Map<String, dynamic> jsonParse = json.decode(response.body);
            Map<String, dynamic> profile = jsonParse['data'];

            setState(() {
                allowedPush = profile['is_push_allowed'];
                allowedFriend = profile['is_friend_request_allowed'];
            });


            print(Provider.of<UserInfoProvider>(context, listen: false).nickname);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
     * @author : hs
     * @date : 2020-01-01
     * @description : 프로필 저장
    */
    Future<void> saveSettingInfo() async {
        try {
            String uri = "/api/v2/user/profile";
            final response = await CallApi.commonApiCall(
                method: HTTP_METHOD.put,
                url: uri,
                data: {
                    "nickname" : Provider.of<UserInfoProvider>(context).nickname,
                    "description" : Provider.of<UserInfoProvider>(context).description,
                    "is_push_allowed"  : allowedPush,
                    "is_friend_request_allowed" : allowedFriend
                }
            );

            return;

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
            return;
        }
    }

    /*
     * @author : hk
     * @date : 2020-01-12
     * @description : 뒤로가기
     */
    void popNav() async {
        Navigator.of(context).pop();
    }

    /*
	 * @author : hk
	 * @date : 2020-01-01
	 * @description : 프로필 사진 업로드
	 */
    void uploadProfileImg(int flag) async {
        SPF = await Constant.getSPF();
	    File imageFile;

	    if(flag == 1){
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
		    Response response = await CallApi.fileUploadCall(url: "/api/v2/user/profile/image", filePath: imageFile.path, onSendProgress: (int sent, int total){

		    });

		    if(response.statusCode == 200){
		    	// 사용자 프로필 캐시 지우고 새로 로딩
			    await Provider.of<UserInfoProvider>(context, listen: false).changedProfileImg();
			    Provider.of<UserInfoProvider>(context, listen: false).createProfileCacheImg();

			    setState((){
				    isLoading = false;
			    });
		    } else {
			    developer.log("## 이미지파일 업로드에 실패하였습니다.");
		    }
	    }
    }

    /*
     * @author : hk
     * @date : 2019-12-31
     * @description : 썸네일 호출 파라미터 제거
     */
    String getOriginImgUri(String uri){
        String processedUrl;

        if(uri.contains("&")){
            String lastParam = uri.substring(uri.lastIndexOf("&"), uri.length);
            if("&type=SMALL" == lastParam) processedUrl = uri.substring(0, uri.lastIndexOf("&"));
        }else{
            processedUrl = uri;
        }

        return processedUrl;
    }

    @override
    Widget build(BuildContext context) {
        return  Scaffold(
            appBar:  AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                title: Text((AppLocalizations.of(context).tr('profile.profileAppbar')),
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil().setSp(16),
                        letterSpacing: ScreenUtil().setWidth(-0.8),
                    ),
                ),
                leading:  IconButton(
                    icon:  Image.asset('assets/images/icon/navIconPrev.png'),
                    onPressed: (){
                        popNav();
                    }
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                brightness: Brightness.light,
            ),
            body:
            Stack(
                children: <Widget>[
                    Column(
                        children: <Widget>[
                            Flexible(
                                child: ListView(
                                    children: <Widget>[
                                        // 프로필 상단 설정
                                        _profileTopSection(context),

                                        // 프로필 설정
                                        _profileSetting(context),

                                        // 앱 설정
                                        _appSetting(context),

                                        // 앱 정보
                                        _appInfo(context),

                                        // 계정 설정
                                        _accountSetting(context)
                                    ]
                                )
                            )
                        ],
                    ),
                    // Loading
                    isLoading ? Loading() : Container()
                ],
            ),
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        );
    }


    /*
     * @author : JH
     * @date : 2020-01-13
     * @description : 프로필 상단 설정
    */
    Widget _profileTopSection(BuildContext context) {
        return Container(
            height: ScreenUtil().setHeight(110),
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setHeight(16),
                horizontal: ScreenUtil().setWidth(16),
            ),
            margin: EdgeInsets.only(
                bottom: 24
            ),
            decoration: BoxDecoration(
                color: Color.fromRGBO(250, 250, 251, 1),
                border: Border(
                    top: BorderSide(
                        width: ScreenUtil().setWidth(0.5),
                        color: Color.fromRGBO(178, 178, 178, 0.8)
                    )
                )
            ),
            child: Row(
                children: <Widget>[
                    // 프로필 이미지
                    _profileImageSection(context),

                    // 닉네임, 소개글
                    _profileNickSection(context),

                    // 편집 버튼
                    _profileEditBtnSection(context),
                ],
            )
        );
    }


    /*
     * @author : JH
     * @date : 2020-01-13
     * @description : 프로필 이미지 설정
    */
    Widget _profileImageSection(BuildContext context) {
        return InkWell(
            child: Container(
                width: ScreenUtil().setWidth(78),
                height: ScreenUtil().setWidth(78),
                margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(4),
                    right: 20,
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: ScreenUtil().setWidth(1),
                        color: Color.fromRGBO(0, 0, 0, 0.05)
                    ),
                    shape: BoxShape.circle
                ),
                child: ClipOval(
                    child: Provider.of<UserInfoProvider>(context).getUserProfileImg()
                ),
            ),
            onTap: () {


                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => FullPhoto(photoUrl: Provider.of<UserInfoProvider>(context).profileURL))
                );

//
//                if (Provider.of<UserInfoProvider>(context).profileURL != null) {
//                    Navigator.push(
//                        context, MaterialPageRoute(
//                        builder: (context) => FullPhoto(photoUrl: Provider.of<UserInfoProvider>(context).profileURL))
//                    );
//                } else {
//
//                }
            },
        );
    }


    /*
     * @author : JH
     * @date : 2020-01-13
     * @description : 닉네임 설정
    */
    Widget _profileNickSection(BuildContext context) {
        String intro = Provider.of<UserInfoProvider>(context).description;
        return Container(
            width: ScreenUtil().setWidth(228.5) - 28,
            margin: EdgeInsets.only(
                right: 8
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(
                            bottom: ScreenUtil().setWidth(8)
                        ),
                        child: Text(
                            Provider.of<UserInfoProvider>(context).nickname ?? "",
                            style: TextStyle(
                                height: 1,
                                fontFamily: "NotoSans",
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenUtil().setSp(17),
                                color: Color.fromRGBO(39, 39, 39, 1)
                            )
                        )
                    ),
                    Text(
                        intro == null || intro == '' ? "소개글을 설정해주세요." : intro,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w400,
                            letterSpacing: ScreenUtil().setWidth(-0.75),
                            fontSize: ScreenUtil().setSp(15),
                            color: Provider.of<UserInfoProvider>(context).description != null ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(107, 107, 107, 0.5)
                        )
                    )
                ],
            )
        );
    }

    /*
     * @author : JH
     * @date : 2020-01-13
     * @description : 프로필 소개 수정 버튼
    */
    Widget _profileEditBtnSection(BuildContext context) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            GestureDetector(
                onTap: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => ProfileDialog(
                            nickName: Provider.of<UserInfoProvider>(context).nickname,
                            intro: Provider.of<UserInfoProvider>(context).description,
                            leftButtonText: (AppLocalizations.of(context).tr('profile.cancel')),
                            rightButtonText: (AppLocalizations.of(context).tr('save')),
                            profileImgIdx: Provider.of<UserInfoProvider>(context).profilePictureIdx,
                            // TODO : 명함 불러오기
//                            bCImgIdx: ,
                        ),
                    ).then((onValue) {

                    });
                },
                child: Container(
                    width: ScreenUtil().setWidth(28.5),
                    height: ScreenUtil().setWidth(28.5),
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setHeight(12.25)
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/icon/editButton.png',
                            ),
                            fit: BoxFit.cover
                        )
                    ),
                )
                )
            ],
        );
    }

//    uploadProfileImg(1); 앨범
//    uploadProfileImg(2); 앨범


    Widget _profileSetting(BuildContext context) {
        return Container(
            margin: EdgeInsets.only(
                bottom: 12
            ),
            child: Column(
                children: <Widget>[
                    buildSettingHeader((AppLocalizations.of(context).tr('profile.profile'))),

                    buildTextInfoItem((AppLocalizations.of(context).tr('profile.phoneNumber')), Provider.of<UserInfoProvider>(context).phoneNumber),

                    buildTextItem((AppLocalizations.of(context).tr('profile.bncardManage')), "", () {})
                ]
            ),
        );
    }

    /*
     * @author : JH
     * @date : 2020-01-13
     * @description : 푸쉬 알림 설정
    */

    Widget _appSetting(BuildContext context){
        return Container(
            margin: EdgeInsets.only(
                bottom: 12
            ),
            child: Column(
                children: <Widget>[
                    buildSettingHeader(AppLocalizations.of(context).tr('profile.appSetting')),

                    buildSwitchItem(
                        (AppLocalizations.of(context).tr('profile.pushAlarm')),
                        allowedPush,
                        (bool value) {
                            setState(() {
                                allowedPush = value;
                            });
                        }
                    ),
                    buildSwitchItem(
                        (AppLocalizations.of(context).tr('profile.friendAllow')),
                        allowedFriend,
                        (bool value) {
                            developer.log(value.toString());
                            setState(() {
                                allowedFriend = value;
                            });
                        }
                    ),
                ]
            )
        );
    }
    /*
     * @author : JH
     * @date : 2020-01-13
     * @description : 앱 정보
    */

    Widget _appInfo(BuildContext context){
        return Container(
            margin: EdgeInsets.only(
                bottom: 12
            ),
            child: Column(
                children: <Widget>[
                    buildSettingHeader(AppLocalizations.of(context).tr('profile.appInfo')),

                    buildTextInfoItem(AppLocalizations.of(context).tr('profile.appVer'), appVersion ),

                    buildTextItem(AppLocalizations.of(context).tr('profile.termsAndCondition'), "", null),

                    buildTextItem(
                        (AppLocalizations.of(context).tr('profile.opensource')),
                        "",
                            () {
                            Navigator.pushNamed(context, "/opensource");
                        }
                    ),

                ]
            )
        );
    }

    /*
     * @author : JH
     * @date : 2020-01-13
     * @description : 계정 설정
    */
    Widget _accountSetting(BuildContext context){
      return Container(
          margin: EdgeInsets.only(
              bottom: 12
          ),
          child: Column(
              children: <Widget>[
                  buildSettingHeader((AppLocalizations.of(context).tr('profile.account'))),

                  InkWell(
                      child: buildTextItem((AppLocalizations.of(context).tr('profile.logout')), "", null),
                      onTap:() {
                          logOut();
                      }
                  ),

                  buildTextItem((AppLocalizations.of(context).tr('profile.leave')), "", null)
              ]
          )
      );
    }

    Widget buildSettingHeader(String title) {
        return Container(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16)
            ),
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil().setHeight(29),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: Color.fromRGBO(235, 235, 235, 1)
                    )
                )
            ),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil().setSp(13),
                        letterSpacing: ScreenUtil().setWidth(-0.32)
                    )
                ),
            ),
        );
    }

    Widget buildTextItem(String title, String value, Function fn) {
        return Container(
            height: ScreenUtil().setHeight(52),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(11)
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: title == "명함 관리" || title == "Business card manage" ? Color.fromRGBO(39, 39, 39, 0.3) : Color.fromRGBO(39, 39, 39, 1) ,
                            fontSize: ScreenUtil().setSp(15),
                            letterSpacing: ScreenUtil().setWidth(-0.75)
                        )
                    ),
                    InkWell(
                        child: Row(
                            children: <Widget>[
                                Text(
                                    value ?? "",
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        fontSize: ScreenUtil().setSp(15)
                                    )
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(20),
                                    height: ScreenUtil().setHeight(20),
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(6)
                                    ),
                                    child: title == "명함 관리" || title == "Business card manage" ?
                                    Container(): Image.asset(
                                        'assets/images/icon/iconMore.png',
                                    )
                                )
                            ],
                        ),
                        onTap: (){
                            if (fn != null) fn();
                        },
                    )
                ],
            )
        );
    }

    Widget buildSwitchItem(String title, bool value, Function fn) {
        return Container(
            height: ScreenUtil().setHeight(52),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(16)
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil().setSp(15),
                            letterSpacing: ScreenUtil().setWidth(-0.75)
                        )
                    ),
                    CustomSwitch(
                        onChanged: (val){
                            fn(val);
                        } ,
                        value: value ?? true,
                        inactiveColor: Color.fromRGBO(235, 235, 235, 1),
                        activeColor: Color.fromRGBO(77, 96, 191, 1),
                    )
                ],
            )
        );
    }


    Widget buildTextInfoItem(String title, String value) {
        return Container(
            height: ScreenUtil().setHeight(52),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(16)
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil().setSp(15),
                            letterSpacing: ScreenUtil().setWidth(-0.75)
                        )
                    ),
                    Text(
                        value ?? "",
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(107, 107, 107, 1),
                            fontSize: ScreenUtil().setSp(15)
                        )
                    )
                ],
            )
        );
    }

    Widget policyBtn(String tr) {
      return Container(
          height: ScreenUtil().setHeight(52),
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(16),
              right: ScreenUtil().setWidth(16)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

             Text(
                 (AppLocalizations.of(context).tr('profile.opensource')),
                  style: TextStyle(
                      height: 1,
                      fontFamily: "NotoSans",
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(39, 39, 39, 1),
                      fontSize: ScreenUtil().setSp(15),
                      letterSpacing: ScreenUtil().setWidth(-0.75)
                  )
              ),
            ],
          )
      );
    }
}
