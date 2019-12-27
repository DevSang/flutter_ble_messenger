//pub module
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

//import module
import 'package:Hwa/data/models/chat_user_info.dart';
import 'package:Hwa/utility/cached_image_utility.dart';

class ChatUserList extends StatefulWidget {
    final List<ChatUserInfo> userInfoList;
    ChatUserList({Key key, @required this.userInfoList}) : super(key: key);

    @override
    State createState() => new ChatUserListState();
}


class ChatUserListState extends State<ChatUserList> {
    // 현재 채팅 Advertising condition
    bool openedList;
    // 자신의 방장여부
    bool isHost;

    //About image
    Future<File> profileImageFile;
    Image imageFromPreferences;

    Future setUserProfileImage (ImageSource source, ChatUserInfo userInfo) {
//        CachedImageUtility.saveImageToPreferences(CachedImageUtility.base64String(profileImageFile.readAsBytesSync()));

        setState(() {
            userInfo.profileImg =  ImagePicker.pickImage(source: source);
        });
    }


    @override
    void initState() {
        super.initState();
        openedList = true;
        //TODO: 방장 여부 맵핑
        isHost = false;
    }

    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

        return new Container(
            color: Colors.white,
              child: Column(
                  children: <Widget>[
                      Container(
                          width: ScreenUtil().setWidth(620),
                          height: ScreenUtil().setWidth(64),
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(40),
                            right:   ScreenUtil().setWidth(36)
                          ),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              border: Border(
                                  top: BorderSide(
                                      width: ScreenUtil().setWidth(1),
                                      color: Color.fromRGBO(39, 39, 39, 0.15)
                                  )
                              )
                          ),
                          child:
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                  Container(
                                      child: Row(
                                          children: <Widget>[
                                              Text(
                                                  widget.userInfoList[0].partType == "BLE"
                                                      ? "내 주변 사람"
                                                      : (
                                                      widget.userInfoList[0].partType == "Online"
                                                          ? "온라인 유저"
                                                          : "관전 유저"
                                                  ),
                                                  style: TextStyle(
                                                      height: 1,
                                                      fontSize: ScreenUtil().setSp(26),
                                                      letterSpacing: ScreenUtil().setWidth(-0.33),
                                                      color: Color.fromRGBO(39, 39, 39, 1)
                                                  ),
                                              ),
                                              Container(
                                                  height: ScreenUtil().setHeight(26),
                                                  padding: EdgeInsets.only(
                                                      left: ScreenUtil().setWidth(16),
                                                      right: ScreenUtil().setWidth(16),
                                                  ),
                                                  child: Text(
                                                      widget.userInfoList.length.toString(),
                                                      style: TextStyle(
                                                          height: 1,
                                                          fontSize: ScreenUtil().setSp(26),
                                                          letterSpacing: ScreenUtil().setWidth(-0.33),
                                                          color: Color.fromRGBO(107, 107, 107, 1)
                                                      ),
                                                  ),
                                              ),
                                          ],
                                      )
                                  ),
                                  Container(
                                      width: ScreenUtil().setWidth(40),
                                      child: FlatButton(
                                          onPressed:(){
                                              setState(() {
                                                  openedList = !openedList;
                                              });
                                          }
                                      ),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image:AssetImage(openedList
                                                                ? "assets/images/icon/iconFold.png"
                                                                : "assets/images/icon/iconExpand.png")
                                          ),
                                      ),
                                  )
                              ],
                          ),
                      ),
                      openedList
                          ? Container(
                               child: ListView.builder(
                                   physics: new NeverScrollableScrollPhysics(),
                                   shrinkWrap: true,
                                   itemCount: widget.userInfoList.length,
                                   itemBuilder: (BuildContext context, int index){
                                       return BuildUserInfo(isHost: isHost, userInfo: widget.userInfoList[index], setUserProfileImage: setUserProfileImage);
                                   }
                               ),
                          )
                          : Container(),

                  ],
              )
          );
    }
}

class BuildUserInfo extends StatelessWidget {
    final bool isHost;
    final ChatUserInfo userInfo;
    final Function setUserProfileImage;
    BuildUserInfo({Key key, @required this.isHost, this.userInfo, this.setUserProfileImage});
    @override
    Widget build(BuildContext context) {
        print(userInfo.nick + userInfo.profileImg.toString());

        return InkWell(
            child: Stack(
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(40),
                            right: ScreenUtil().setWidth(36)
                        ),
                        height: ScreenUtil().setHeight(104),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Container(
                                    width: ScreenUtil().setWidth(504),
                                    child: Row(
                                        children: <Widget>[
                                            // 프로필 이미지
                                            Container(
                                                child: ClipRRect(
                                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(70)),
                                                    child: Image.asset(
                                                        "assets/images/profile_img.png",
                                                        width: ScreenUtil().setWidth(80),
                                                        height: ScreenUtil().setWidth(80),
                                                    )
                                                 )
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(21)
                                                ),
                                                child: Text(
                                                    userInfo.nick,
                                                    style: TextStyle(
                                                        height: 1,
                                                        fontSize: ScreenUtil().setSp(26),
                                                        letterSpacing: ScreenUtil().setWidth(-0.33),
                                                        color: Color.fromRGBO(39, 39, 39, 1)
                                                    ),
                                                )
                                            ),
                                        ],
                                    ),
                                ),
                                // 연락처 아이콘
                                userInfo.existContact ? contactIcon : new Container()
                            ],
                        )
                    ),
                    // 방장 뱃지
                    userInfo.isHost ? badgeHost : new Container(),

                    // 자신 뱃지
                    userInfo.isMe ? badgeMe : new Container(),
                ],
            ),
            onTap: (){
                /// 프로필 팝업
                _showModalSheet(context, userInfo);
            },
        );
    }

    Widget contactIcon = new Container(
        width: ScreenUtil().setWidth(40),
        height: ScreenUtil().setHeight(40),
        decoration: BoxDecoration(
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconAddress.png")
            ),
        )
    );

    Widget badgeHost = new Positioned(
        top: ScreenUtil().setHeight(40),
        left: ScreenUtil().setWidth(15),
        child: GestureDetector(
            child: Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setHeight(40),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(77, 96, 191, 1),
                    image: DecorationImage(
                        image:AssetImage("assets/images/icon/iconMasterBadge.png")
                    ),
                    shape: BoxShape.circle
                )
            )
        )
    );

    Widget badgeMe = new Positioned(
        top: ScreenUtil().setHeight(40),
        left: ScreenUtil().setWidth(15),
        child: GestureDetector(
            child: Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setHeight(40),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        "나",
                        style: TextStyle(
                            height: 1,
                            color: Colors.white,
                            fontSize: ScreenUtil().setWidth(20)
                        ),
                    )
                )
            )
        )
    );

    void _showModalSheet(BuildContext context, ChatUserInfo userInfo) {
        showModalBottomSheet(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(30)),
                    topRight: Radius.circular(ScreenUtil().setWidth(30)),
                ),
            ),
            context: context,
            builder: (builder) {
                return Container(
                    height: ScreenUtil().setHeight(598),
                    decoration: BoxDecoration(
                    ),
                    child: Column(
                        children: <Widget>[
                            Container(
                                width: ScreenUtil().setWidth(750),
                                height: ScreenUtil().setHeight(104),
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(36),
                                    right: ScreenUtil().setWidth(36)
                                ),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: ScreenUtil().setWidth(2),
                                            color: Color.fromRGBO(39, 39, 39, 0.15)
                                        )
                                    )
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Container(
                                            width: ScreenUtil().setWidth(54),
                                            height: ScreenUtil().setHeight(54),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:AssetImage(
                                                        userInfo.businessCard != ""
                                                        ? "assets/images/icon/iconViewCard.png"
                                                        : "")
                                                )
                                            )
                                        ),
                                        Container(
                                            child: Text(
                                                userInfo.nick,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    height: 1,
                                                    fontSize: ScreenUtil().setSp(32),
                                                    letterSpacing: ScreenUtil().setWidth(-0.8),
                                                    color: Color.fromRGBO(39, 39, 39, 1)
                                                ),
                                            )
                                        ),
                                        Container(
                                            width: ScreenUtil().setWidth(40),
                                            height: ScreenUtil().setHeight(40),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:AssetImage("assets/images/icon/iconClosePopup.png")
                                                )
                                            ),
                                            child: FlatButton(
                                                onPressed:(){
                                                    Navigator.pop(context);
                                                }
                                            ),
                                        ),
                                    ],
                                )
                            ),
                            Container(
                                height: ScreenUtil().setHeight(492),
                                child: Column(
                                    children: <Widget>[
                                        GestureDetector(
                                            child: Container(
                                                width: ScreenUtil().setWidth(180),
                                                height: ScreenUtil().setWidth(180),
                                                margin: EdgeInsets.only(
                                                    top: ScreenUtil().setHeight(32),
                                                    bottom: ScreenUtil().setHeight(26),
                                                ),
                                                child: ClipRRect(
                                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(70)),
                                                    child:
                                                        Image.asset(
                                                            "assets/images/profile_img.png",
                                                            width: ScreenUtil().setWidth(80),
                                                            height: ScreenUtil().setWidth(80),
                                                        ),
                                                )
                                            ),onTap: () {
                                                setUserProfileImage(ImageSource.gallery, userInfo);
                                            },
                                        ),
                                        Container(
                                            height: ScreenUtil().setHeight(24),
                                            child: Text(
                                                userInfo.userIntro,
                                                style: TextStyle(
                                                    height: 1,
                                                    fontSize: ScreenUtil().setSp(26),
                                                    letterSpacing: ScreenUtil().setWidth(-0.33),
                                                    color: Color.fromRGBO(107, 107, 107, 1)
                                                ),
                                            )
                                        ),
                                        Container(
                                            width: ScreenUtil().setWidth(718),
                                            padding: EdgeInsets.only(
                                                left: ScreenUtil().setWidth(16),
                                                right: ScreenUtil().setWidth(16),
                                            ),
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(42),
                                            ),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                    userInfo.addFriend
                                                        ? userFunc("assets/images/icon/iconRequest.png", "친구 요청", null)
                                                        : Container()
                                                    ,
                                                    userFunc("assets/images/icon/iconDirectChat.png", "1:1 채팅", null),
                                                    userFunc("assets/images/icon/iconBlock.png", "차단하기", null),
                                                    isHost
                                                        ? userFunc("assets/images/icon/iconEject.png", "내보내기", null)
                                                        : Container()
                                                ],
                                            ),
                                        )
                                    ],
                                )
                            )
                        ],
                    ),
                );
            }
        );
    }

    Widget userFunc(String iconSrc, String title,Function fn) {
        return new Container(
            width: ScreenUtil().setWidth(179.5),
            child: Column(
                children: <Widget>[
                    GestureDetector(
                        child: Container(
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(18),
                            ),
                            width: ScreenUtil().setWidth(100),
                            height: ScreenUtil().setHeight(100),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(210, 217, 250, 1),
                                image: DecorationImage(
                                    image:AssetImage(iconSrc)
                                ),
                                shape: BoxShape.circle
                            )
                        ),
                        onTap:(){
                            fn();
                        }
                    ),
                    Container(
                        height: ScreenUtil().setHeight(24),
                        child:
                        Text(
                            title,
                            style: TextStyle(
                                height: 1,
                                fontSize: ScreenUtil().setSp(26),
                                letterSpacing: ScreenUtil().setWidth(-0.33),
                                color: Color.fromRGBO(107, 107, 107, 1)
                            ),
                        )
                    )
                ],
            ),
        );
    }
}