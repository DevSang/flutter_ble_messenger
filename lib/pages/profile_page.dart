import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/parts/loading.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/custom_dialog.dart';
import 'package:Hwa/pages/signin_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';


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

    String profileImgUri = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + Constant.USER_IDX.toString() + "&type=SMALL";

    CachedNetworkImage cachedNetworkImage;

    @override
    void initState() {
        isLoading = false;

        cachedNetworkImage = CachedNetworkImage(
            imageUrl: profileImgUri,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Image.asset('assets/images/icon/profile.png',fit: BoxFit.cover),
            httpHeaders: Constant.HEADER
        );

        getSettingInfo();

	    super.initState();
    }

  /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 로그아웃
    */
    Future<void> logOut() async {
        SPF = await SharedPreferences.getInstance();
        await store.onReady;
        await SPF.remove('token');
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
            String uri = "/api/v2/user/profile?target_user_idx=" + Constant.USER_IDX.toString();
            final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

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
    void saveSettingInfo() async {
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

            print("####" + response.body.toString());

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }


    void popNav() async {
        setState(() {
            isLoading = true;
        });

        await saveSettingInfo();

        setState(() {
            isLoading = false;
        });

        Navigator.of(context).pop();
    }

    /*
	 * @author : hk
	 * @date : 2020-01-01
	 * @description : 프로필 사진 업로드
	 */
    void uploadProfileImg(int flag) async {
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
			    print("$sent : $total");
		    });

		    if(response.statusCode == 200){
			    await DefaultCacheManager().removeFile(profileImgUri);

			    setState(() {
				    cachedNetworkImage = CachedNetworkImage(
						    imageUrl: profileImgUri,
						    placeholder: (context, url) => CircularProgressIndicator(),
						    errorWidget: (context, url, error) => Icon(Icons.error),
						    httpHeaders: Constant.HEADER
				    );

				    Constant.IS_CHANGE_PROFILE_IMG = true;

                    isLoading = false;
			    });
		    } else {
			    developer.log("## 이미지파일 업로드에 실패하였습니다.");
		    }
	    }
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                title: Text(
                    "프로필 설정",
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16)
                    ),
                ),
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconPrev.png'),
                    onPressed: (){
                        popNav();
                    }
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
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
                                        // 프로필 이미지
                                        _profileImageSection(context),

                                        // 프로필 설정
                                        _profileSetting(context),

                                        // 앱 설정
                                        _appSetting(context),

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
            )
        );
    }


    Widget _profileImageSection(BuildContext context) {
        return Container(
              width: ScreenUtil().setWidth(375),
              height: ScreenUtil().setHeight(178),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(178, 178, 178, 1),
              ),
              child: Stack(
                  children: <Widget>[
                      InkWell(
                          child: Center(
                              child: Container(
                                  width: ScreenUtil().setHeight(90),
                                  height: ScreenUtil().setHeight(90),
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(41),
                                      bottom: ScreenUtil().setHeight(46),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: ScreenUtil().setWidth(1),
                                          color: Color.fromRGBO(0, 0, 0, 0.05)
                                      ),
                                      borderRadius: new BorderRadius.circular(ScreenUtil().setHeight(45)),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: new BorderRadius.circular(ScreenUtil().setHeight(45)),
                                      child: cachedNetworkImage
//	                                  child: proFileImgUri == null
//	                                      ? Image.asset('assets/images/icon/thumbnailUnset1.png',fit: BoxFit.cover)
//	                                      : Image.network(proFileImgUri, scale: 1.0, headers: header)
                                  ),
                              ),
                          ),
                          onTap: () {
                          	  uploadProfileImg(1);
                          },
                      ),
                      Positioned(
                          bottom: ScreenUtil().setHeight(41),
                          left: ScreenUtil().setWidth(206),
                          child: InkWell(
                              child: Container(
                                  width: ScreenUtil().setWidth(32),
                                  height: ScreenUtil().setHeight(32),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(77, 96, 191, 1),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/icon/iconAttachCamera.png")
                                      ),
                                      shape: BoxShape.circle
                                  )
                              ),
                              onTap: () {
                              	  uploadProfileImg(2);
                              }
                          )
                      )
                  ],
              ),
        );
    }

    Widget _profileSetting(BuildContext context) {
        return Container(
            child: Column(
                children: <Widget>[
                    buildSettingHeader("프로필"),

                    buildTextItem(
                        "사용자 이름",
                        nickName,
                        false,
                        (dynamic value)  {
                            setState(() {
                                nickName = value;
                            });
                        }
                    ),

                    buildTextItem(
                        "한 줄 소개",
                        intro,
                        false,
                        (dynamic value)  {
                            setState(() {
                                intro = value;
                            });
                        }
                    ),

                    buildTextInfoItem("연락처", phoneNum, true),

//                    buildTextItem("명함 관리", "", true)
                ]
            ),
        );
  }

  Widget _appSetting(BuildContext context){
      return Container(
          child: Column(
              children: <Widget>[
                  buildSettingHeader("앱 설정"),

                  buildSwitchItem(
                      "푸쉬 알림",
                      allowedPush,
                      false,
                      (bool value) {
                          setState(() {
                              allowedPush = value;
                          });
                      }
                  ),

                  buildSwitchItem(
                      "친구 요청 허용",
                      allowedFriend,
                      true,
                      (bool value) {
                          print(value);
                          setState(() {
                              allowedFriend = value;
                          });
                      }
                  ),
              ]
          )
      );
  }


    Widget _accountSetting(BuildContext context){
      return Container(
          child: Column(
              children: <Widget>[
                  buildSettingHeader("계정"),

                  InkWell(
                      child: buildTextItem("로그아웃", "", false, null),
                      onTap:() {
                          logOut();
                      }
                  ),

                  buildTextInfoItem("탈퇴하기", "", true),

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
            height: ScreenUtil().setHeight(25),
            decoration: BoxDecoration(
                color: Color.fromRGBO(235, 235, 235, 1),
            ),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(13),
                        letterSpacing: ScreenUtil.getInstance().setWidth(-0.65)
                    )
                ),
            ),
        );
    }

    Widget buildTextItem(String title, String value, bool isLast, Function fn) {
                return Container(
            height: ScreenUtil().setHeight(49),
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16)
            ),
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(8)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: isLast ? Colors.white : Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
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
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Container(
                        child: InkWell(
                            child: Row(
                                children: <Widget>[
                                    Text(
                                        value ?? "",
                                        style: TextStyle(
                                            height: 1,
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromRGBO(107, 107, 107, 1),
                                            fontSize: ScreenUtil.getInstance().setSp(15),
                                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
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
                                        leftButtonText: "취소",
                                        rightButtonText: "저장하기",
                                        value: value,
                                        hintText: value == null ? "소개글을 입력해 보세요 :)" : ""
                                    ),
                                ).then((onValue) {
                                    if (fn != null) fn(onValue);
                                });
                            },
                        )
                    )
                ],
            )
        );
    }

    Widget buildSwitchItem(String title, bool value, bool isLast, Function fn) {
        return Container(
            height: ScreenUtil().setHeight(49),
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16)
            ),
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(8)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: isLast ? Colors.white : Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
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
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    CustomSwitch(
                        onChanged: (val){
                            fn(val);
                        } ,
                        value: value ?? true,
                        inactiveColor: Color.fromRGBO(235, 235, 235, 1),
                        activeColor: Color.fromRGBO(77, 96, 191, 1),
                        shadow: BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            offset: new Offset(
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setWidth(0)
                            ),
                            blurRadius: 2
                        )
                    )
                ],
            )
        );
    }


    Widget buildTextInfoItem(String title, String value, bool isLast) {
        return Container(
            height: ScreenUtil().setHeight(49),
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16)
            ),
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(16)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: isLast ? Colors.white : Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
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
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Text(
                        value ?? "",
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(107, 107, 107, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    )
                ],
            )
        );
    }
}
