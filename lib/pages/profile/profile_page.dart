import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/custom_switch.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/custom_dialog.dart';
import 'package:Hwa/pages/signin/signin_page.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Hwa/utility/validators.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State <ProfilePage>{
    SharedPreferences SPF;
    final store = KvStore();

    bool isSwitched = true;
    double sameSize = GetSameSize().main();

    String nickName;
    String intro;
    String phoneNum;
    bool allowedPush;
    bool allowedFriend;

    bool isLoading;

    @override
    void initState() {
        isLoading = false;
        getSettingInfo();
	    super.initState();
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
                nickName = profile['nickname'];
                intro = profile['description'];
                phoneNum = profile['phone_number'];
                allowedPush = profile['is_push_allowed'];
                allowedFriend = profile['is_friend_request_allowed'];
            });

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
                    "nickname" : nickName,
                    "description" : intro,
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
        );
    }

    Widget _profileNickSection(BuildContext context) {
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
                            nickName ?? "",
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
                        intro ?? "안녕하세요 :) " + (nickName ?? "") + "입니다. ",
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w400,
                            letterSpacing: ScreenUtil().setWidth(-0.75),
                            fontSize: ScreenUtil().setSp(15),
                            color: Color.fromRGBO(107, 107, 107, 1)
                        )
                    )
                ],
            )
        );
    }

    Widget _profileEditBtnSection(BuildContext context) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            GestureDetector(
                 onTap: (){
                     print("Container Clicked");
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

                    buildTextInfoItem((AppLocalizations.of(context).tr('profile.phoneNumber')), phoneNum),

                    buildTextItem((AppLocalizations.of(context).tr('profile.bncardManage')), "", () {})
                ]
            ),
        );
    }

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

    Widget _appInfo(BuildContext context){
        return Container(
            margin: EdgeInsets.only(
                bottom: 12
            ),
            child: Column(
                children: <Widget>[
                    buildSettingHeader(AppLocalizations.of(context).tr('profile.appInfo')),

                    buildTextInfoItem(AppLocalizations.of(context).tr('profile.appVer'), "0.0.5"),

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
                            color: Color.fromRGBO(39, 39, 39, 1),
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
                                    child: Image.asset(
                                        'assets/images/icon/iconMore.png'
                                    )
                                )
                            ],
                        ),
                        onTap: (){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => CustomDialog(
                                    title: title,
                                    type: 1,
                                    leftButtonText: (AppLocalizations.of(context).tr('profile.cancel')),
                                    rightButtonText: (AppLocalizations.of(context).tr('save')),
                                    value: value,
                                    hintText: value == null ? (AppLocalizations.of(context).tr('profile.textIntroduce')) : ""
                                ),
                            ).then((onValue) {
                                if (fn != null && onValue != null) fn(onValue);
                            });
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
