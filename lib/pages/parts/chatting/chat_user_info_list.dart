import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/red_toast.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/pages/parts/chatting/full_photo.dart';
import 'package:Hwa/data/state/user_info_provider.dart';




/*
 * @project : HWA - Mobile
 * @author : SH
 * @date : 2020-01-01
 * @description : 단화방 - 사이드메뉴 - 유저 - 유저
 */
class ChatUserInfoList extends StatefulWidget {
    final int hostIdx;
    final ChatJoinInfo userInfo;

    ChatUserInfoList({Key key, @required this.userInfo, this.hostIdx}) : super(key: key);

    @override
    State createState() => new ChatUserInfoListState(userInfo: userInfo, hostIdx: hostIdx);
}

class ChatUserInfoListState extends State<ChatUserInfoList> with TickerProviderStateMixin {
    final int hostIdx;
    final ChatJoinInfo userInfo;
    double sameSize = GetSameSize().main();

    ChatUserInfoListState({Key key, @required this.hostIdx, this.userInfo});

    //TODO 추후에 관계요청 리스트에서 받아와야함
    bool isSendRequestFriend = false;

    @override
    void initState() {
        super.initState();
    }

    /*
    * @author : sh
    * @date : 2020-01-01
    * @description : 친구요청 함수
    */
    requestFriend (int targetIdx, StateSetter setStateBuild) async {
        String uri = "/api/v2/relation/request?target_user_idx=" + targetIdx.toString();
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.post, url: uri);

        if(response.statusCode == 200){
            setState(() {
                developer.log("## 친구요청에 성공하였습니다.");
                setStateBuild(() {
                    isSendRequestFriend = true;
                });
            });
        } else {
            RedToast.toast("서버 요청에 실패하였습니다. 잠시 후 다시 시도해주세요.", ToastGravity.TOP);
            developer.log("## 친구요청에 실패하였습니다.");
        }
    }

    @override
    Widget build(BuildContext context) {
        return new InkWell(
            child: AnimatedSize(
                curve: Curves.ease,
                vsync: this,
                duration: new Duration(milliseconds: 500),
                child: Stack(
                    children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20),
                                right: ScreenUtil().setWidth(18)
                            ),
                            height: ScreenUtil().setHeight(52),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(252),
                                        child: Row(
                                            children: <Widget>[
                                                // 프로필 이미지
                                                Container(
                                                    child: ClipRRect(
                                                        borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(70)),
                                                        child: FadeInImage(
                                                            width: ScreenUtil().setHeight(40),
                                                            height: ScreenUtil().setHeight(40),
                                                            placeholder: AssetImage("assets/images/icon/profile.png"),
                                                            image: userInfo.profilePictureIdx == null ? AssetImage("assets/images/icon/profile.png") :
                                                                    CachedNetworkImageProvider(Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + userInfo.userIdx.toString() + "&type=SMALL", headers: Constant.HEADER),
                                                            fit: BoxFit.cover,
                                                            fadeInDuration: Duration(milliseconds: 1)
                                                        )
                                                    )
                                                ),
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        left: ScreenUtil().setWidth(10.1)
                                                    ),
                                                    child: Text(
                                                        userInfo.userNick ?? "",
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: 'NotoSans',
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: ScreenUtil().setSp(13),
                                                            letterSpacing: ScreenUtil().setWidth(-0.32),
                                                            color: Color.fromRGBO(39, 39, 39, 1)
                                                        ),
                                                    )
                                                ),
                                            ],
                                        ),
                                    ),
                                    // TODO: 연락처 아이콘
    //                                userInfo.existContact ? contactIcon : new Container()
                                ],
                            )
                        ),
                        // 자신 뱃지
                        userInfo.userIdx == Constant.USER_IDX ? badgeMe : new Container(),

                        // 방장 뱃지
                        userInfo.userIdx == hostIdx ? badgeHost : new Container(),
                    ],
                )
            ),
            onTap: (){
                /// 프로필 팝업
                _showModalSheet(context, userInfo);
            },
        );
    }

    Widget contactIcon = new Container(
        width: ScreenUtil().setWidth(20),
        height: ScreenUtil().setHeight(20),
        decoration: BoxDecoration(
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconAddress.png")
            ),
        )
    );

    Widget badgeHost = new Positioned(
        top: ScreenUtil().setHeight(17),
        left: ScreenUtil().setWidth(12),
        child: GestureDetector(
            child: Container(
                width: ScreenUtil().setHeight(18),
                height: ScreenUtil().setHeight(18),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(77, 96, 191, 1),
                    image: DecorationImage(
                        image:AssetImage(
                            "assets/images/icon/iconMasterBadge.png")
                    ),
                    shape: BoxShape.circle
                )
            )
        )
    );

    Widget badgeMe = new Positioned(
        top: ScreenUtil().setHeight(17),
        left: ScreenUtil().setWidth(12),
        child: GestureDetector(
            child: Container(
                width: ScreenUtil().setHeight(18),
                height: ScreenUtil().setHeight(18),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(239, 193, 0, 1),
                    shape: BoxShape.circle
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        "나",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setWidth(10)
                        ),
                    )
                )
            )
        )
    );

    _showModalSheet(BuildContext context, ChatJoinInfo userInfo) {
        return showModalBottomSheet(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(15)),
                    topRight: Radius.circular(ScreenUtil().setWidth(15)),
                ),
            ),
            context: context,
            builder: (builder) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setStateBuild){
                        return Container(
                            height: userInfo.userIdx == Constant.USER_IDX ? ScreenUtil().setHeight(200) : ScreenUtil().setHeight(299),
                            decoration: BoxDecoration(
                            ),
                            child: Column(
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(375),
                                        height: ScreenUtil().setHeight(52),
                                        padding: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(18),
                                            right: ScreenUtil().setWidth(18)
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    width: ScreenUtil().setWidth(1),
                                                    color: Color.fromRGBO(39, 39, 39, 0.15)
                                                )
                                            )
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                                Container(
                                                    width: ScreenUtil().setWidth(27),
                                                    height: ScreenUtil().setHeight(27),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:AssetImage(
                                                                "assets/images/icon/iconViewCard.png"
                                                                // TODO: 명함 맵핑
//                                                        userInfo.businessCard != ""
//                                                        ? "assets/images/icon/iconViewCard.png"
//                                                        : ""
                                                            )
                                                        )
                                                    )
                                                ),
                                                Container(
                                                    child: Text(
                                                        userInfo.userNick.toString(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontSize: ScreenUtil().setSp(16),
                                                            letterSpacing: ScreenUtil().setWidth(-0.8),
                                                            color: Color.fromRGBO(39, 39, 39, 1)
                                                        ),
                                                    )
                                                ),
                                                Container(
                                                    width: ScreenUtil().setWidth(20),
                                                    height: ScreenUtil().setHeight(20),
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
                                        height: userInfo.userIdx == Constant.USER_IDX ? ScreenUtil().setHeight(148) : ScreenUtil().setHeight(246),
                                        child: Column(
                                            children: <Widget>[
                                                InkWell(
                                                    child: Container(
                                                        width: ScreenUtil().setHeight(90),
                                                        height: ScreenUtil().setHeight(90),
                                                        margin: EdgeInsets.only(
                                                            top: ScreenUtil().setHeight(17),
                                                            bottom: ScreenUtil().setHeight(13.5),
                                                        ),
                                                        child: ClipRRect(
                                                            borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(70)),
                                                            child: FadeInImage(
                                                                placeholder: AssetImage(
                                                                    "assets/images/icon/profile.png"
                                                                ),
                                                                image: NetworkImage(
                                                                    Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + userInfo.userIdx.toString() + "&type=BIG"
                                                                    , scale: 1
                                                                    , headers: Constant.HEADER
                                                                ),
                                                                fit: BoxFit.cover,
                                                                fadeInDuration: Duration(milliseconds: 1)
                                                            )
                                                        )
                                                    ),
                                                    onTap: () {
                                                        if(Provider.of<UserInfoProvider>(context, listen: false).cacheProfileImg.errorWidget == null) {
                                                            Navigator.push(
                                                                context, MaterialPageRoute(
                                                                builder: (context) => FullPhoto(
		                                                                photoUrl: Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + userInfo.userIdx.toString() + "&type=BIG"
                                                                )
                                                            ));
                                                        }
                                                    },
                                                ),
                                                Container(
                                                    height: ScreenUtil().setHeight(12),
                                                    child: Text(
                                                        // TODO: 인삿말 맵핑
                                                        userInfo.description.toString() == 'null' ? "" : userInfo.description.toString(),
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontSize: ScreenUtil().setSp(13),
                                                            letterSpacing: ScreenUtil().setWidth(-0.33),
                                                            color: Color.fromRGBO(107, 107, 107, 1)
                                                        ),
                                                    )
                                                ),
                                                userInfo.userIdx == Constant.USER_IDX ? Container() : Container(
                                                    width: ScreenUtil().setWidth(359),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: ScreenUtil().setWidth(8)
                                                    ),
                                                    margin: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(21),
                                                    ),
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children:  <Widget> [
                                                            isSendRequestFriend ?
                                                            userFunc("assets/images/icon/iconRequestCalling.png", AppLocalizations.of(context).tr('tabNavigation.friend.friendRequestComplete'), null, userInfo.userIdx, setStateBuild)
                                                                : userFunc("assets/images/icon/iconRequest.png", AppLocalizations.of(context).tr('tabNavigation.friend.friendRequest'), requestFriend, userInfo.userIdx, setStateBuild),
                                                            userFunc("assets/images/icon/iconDirectChat.png", AppLocalizations.of(context).tr('tabNavigation.friend.personalChat'), null, userInfo.userIdx, setStateBuild),
                                                            userFunc("assets/images/icon/iconBlock.png", AppLocalizations.of(context).tr('tabNavigation.friend.block'), null, userInfo.userIdx, setStateBuild),
                                                            hostIdx  == Constant.USER_IDX ? userFunc("assets/images/icon/iconEject.png", AppLocalizations.of(context).tr('tabNavigation.friend.ban'), null, userInfo.userIdx, setStateBuild) : Container()
                                                        ]
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
        );
    }

    Widget userFunc(String iconSrc, String title,Function fn, int userIdx, StateSetter setStateBuild) {
        return new Container(
            width: ScreenUtil().setWidth(85.75),
            child: Column(
                children: <Widget>[
                    GestureDetector(
                        child: Container(
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(9),
                            ),
                            width: sameSize*50,
                            height: sameSize*50,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(210, 217, 250, 1),
                                image: DecorationImage(
                                    image:AssetImage(iconSrc)
                                ),
                                shape: BoxShape.circle
                            )
                        ),
                        onTap:(){
                            fn(userIdx, setStateBuild);
                        }
                    ),
                    Container(
                        height: ScreenUtil().setHeight(12),
                        child:
                        Text(
                            title,
                            style: TextStyle(
                                height: 1,
                                fontSize: ScreenUtil().setSp(13),
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