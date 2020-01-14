import 'dart:developer' as developer;
import 'dart:convert';

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/pages/parts/chatting/full_photo.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/data/models/friend_request_info.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/data/state/friend_list_info_provider.dart';
import 'package:Hwa/data/state/friend_request_list_info_provider.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-30
 * @description : HWA 친구 Tab 화면 
 */
class User {
    final String name;
    final String company;
    final bool favorite;

    User(this.name, this.company, this.favorite);
}

class FriendTab extends StatefulWidget {
    @override
    FriendTabState createState() => FriendTabState();
}

class FriendTabState extends State<FriendTab> with TickerProviderStateMixin {
    final store = KvStore();
    FriendListInfoProvider friendListInfoProvider;
    FriendRequestListInfoProvider friendRequestListInfoProvider;

    List<FriendInfo> originList;              // 원본 친구 리스트
    List<FriendInfo> friendList;              // 화면에 보이는 친구 리스트 (검색 용도)
    List<FriendRequestInfo> requestList;

    TextEditingController searchController = TextEditingController();
    double sameSize;
    bool isLoading;
    int requestListHeight;
    bool requestExpandFlag;
    bool isSearching;

    @override
    void initState() {
        friendListInfoProvider = Provider.of<FriendListInfoProvider>(context, listen: false);
        friendRequestListInfoProvider = Provider.of<FriendRequestListInfoProvider>(context, listen: false);

        searchController.addListener(() {
            if (searchController.text.length > 0) {
                searchFriends();
            } else {
                setState(() {
                    isSearching = false;
                });
            }
        });

        _initState();

        sameSize = GetSameSize().main();
        isLoading = false;
        isSearching = false;

        super.initState();
    }

    /*
     * @author :sh
     * @date : 2020-01-01
     * @description : 친구리스트 초기화
     */
    void _initState() async {
        setState(() {
            requestListHeight = 100;
            requestExpandFlag = true;
        });
        await setDefaultList();
        friendList.sort((a, b) => a.nickname.compareTo(b.nickname));
    }

    /*
     * @author :sh
     * @date : 2020-01-08
     * @description : Expand onclick
     */
    toggleExpand(){
        setState(() {
            requestExpandFlag = !requestExpandFlag;
            if(requestExpandFlag){
                requestListHeight = 97;
            } else {
                requestListHeight = 31;
            }
        });
    }

    @override
    void dispose() {
        super.dispose();
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : 친구 리스트 검색
    */
    void searchFriends() {
        List<FriendInfo> constList = [];
        constList.addAll(originList);

        friendList.clear();

        constList.retainWhere(
                (user) => user.nickname.toLowerCase().contains(
                searchController.text.toLowerCase()
            )
        );

        setState(() {
            isSearching = true;
            friendList.addAll(constList);
        });
    }

    /*
     * @author : sh
     * @date : 2020-01-08
     * @description : 친구목록 및 요청목록 셋팅
    */
    setDefaultList() async {
        friendList = <FriendInfo>[];
    }

    /*
     * @author : sh
     * @date : 2020-01-01
     * @description : 친구 수락
    */
    approveRequest(dynamic friendInfo, int listIdx) async {
        String uri = "/api/v2/relation/request?req_idx=" + friendInfo.req_idx.toString();
        final response = await CallApi.commonApiCall(
            method: HTTP_METHOD.put,
            url: uri,
        );

        if(response.statusCode == 200){
            friendListInfoProvider.addFriend({
                'user_idx': friendInfo.user_idx,
                'nickname': friendInfo.nickname,
                'phone_number': friendInfo.phone_number,
                'profile_picture_idx': friendInfo.profile_picture_idx.toString() ?? "0",
                'business_card_idx': friendInfo.business_card_idx.toString() ?? "0",
                'user_status': friendInfo.user_status
            });
            friendRequestListInfoProvider.removeFriendRequest(friendInfo.req_idx);
            developer.log("## 친구요청을 수락하였습니다.");
        } else {
            developer.log("## 친구요청을 수락에 실패하였습니다.");
        }
    }

    /*
     * @author : sh
     * @date : 2020-01-01
     * @description : 친구 거절
    */
    rejectRequest(dynamic friendInfo, int listIdx) async {
        String uri = "/api/v2/relation/request?req_idx=" + friendInfo.req_idx.toString();
        final response = await CallApi.commonApiCall(
            method: HTTP_METHOD.patch,
            url: uri,
        );

        if(response.statusCode == 200){
            friendRequestListInfoProvider.removeFriendRequest(friendInfo.req_idx);
            developer.log("## 친구요청을 거절하였습니다.");
        } else {
            developer.log("## 친구요청을 거절에 실패하였습니다.");
        }
    }

    /*
     * @author : hs
     * @date : 2020-01-02
     * @description : 친구 프로필
    */
    _showModalSheet(BuildContext context, dynamic friendInfo) {
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
                        return userProfileModal(context, friendInfo, setStateBuild);
                    }
                );
            }
        );
    }

    /*
     * @author : hs
     * @date : 2020-01-02
     * @description : 1:1 채팅 생성
    */
    void _createChat(FriendInfo friendInfo) async {
        Navigator.pop(context);

        setState(() {
            isLoading = true;
        });

        try {
            String uri = "/danhwa/p2p?opponentIdx=" + friendInfo.user_idx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            developer.log(response.body);
            Map<String, dynamic> jsonParse = json.decode(response.body);
            // 단화방 입장
            _enterChat(jsonParse, friendInfo);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 단화방 입장 파라미터 처리
    */
    void _enterChat(Map<String, dynamic> chatInfoJson, FriendInfo friendInfo) async {

        try {
            ChatInfo chatInfo = new ChatInfo.fromJSON(chatInfoJson);
            bool isLiked = chatInfoJson['isLiked'];
            int likeCount = chatInfoJson['danhwaLikeCount'];

            setState(() {
                isLoading = false;
            });

//            developer.log("################" + chatInfo.toString());
//            developer.log("################**" + isLiked.toString());
//            developer.log("################**" + friendInfo.user_idx.toString());
//            developer.log("################**" + friendInfo.nickname);

            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                    return ChatroomPage(
                        chatInfo: chatInfo,
                        isLiked: isLiked,
                        likeCount: likeCount,
                        isP2P: true,
                        oppIdx: friendInfo.user_idx,
                        oppNick: friendInfo.nickname
                    );
                })
            );

            isLoading = false;
        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    ///############################################################ Widget parts ############################################################################///

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구목록 페이지 build 위젯
    */
    @override
    Widget build(BuildContext context) {
        originList =  Provider.of<FriendListInfoProvider>(context, listen: true).friendList;
        requestList = Provider.of<FriendRequestListInfoProvider>(context, listen: true).friendRequestList;

        if (!isSearching) {
            friendList.clear();
            friendList.addAll(originList);
        }

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                backgroundColor: friendList.length == 0 ? Color.fromRGBO(250, 250, 250, 1) : Color.fromRGBO(255, 255, 255, 1),
                body: buildBody(),
                resizeToAvoidBottomPadding: false,
            )
        );
    }

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 전체 바디 위젯 (친구없을때 배경 포함)
    */
    Widget buildBody() {
        return GestureDetector(
            child: Stack(
                children: <Widget>[
                    ///친구가 한명도 없을때
                    friendList.length == 0 ? Positioned(
                        top : ScreenUtil().setHeight(170),
                        child: Container(
                            width: ScreenUtil().setWidth(375),
                            child : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    Image.asset('assets/images/background/noFriendImg.png'),
                                    Text(
                                        "아직 추가된 친구가 없습니다.",
                                        style: TextStyle(
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w400,
                                            fontSize: ScreenUtil().setSp(14),
                                            letterSpacing: ScreenUtil().setWidth(-0.65),
                                            color: Color.fromRGBO(107,107,107, 1),
                                        ),
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            Text(
                                                "단화방 참여",
                                                style: TextStyle(
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: ScreenUtil().setSp(14),
                                                    letterSpacing: ScreenUtil().setWidth(-0.65),
                                                    color: Color.fromRGBO(107,107,107, 1),
                                                ),
                                            ),
                                            Text(
                                                "를 통해 친구를 만들어 보세요.",
                                                style: TextStyle(
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: ScreenUtil().setSp(14),
                                                    letterSpacing: ScreenUtil().setWidth(-0.65),
                                                    color: Color.fromRGBO(107,107,107, 1),
                                                ),
                                            )
                                        ],
                                    ),
                                ]
                            ),
                        )
                    ) : Container(),
                    Column(
                        children: <Widget>[
                            // 친구 검색
                            buildSearch(),
                            Flexible(
                                child: ListView(
                                    padding: EdgeInsets.all(0),
                                    children: <Widget>[
                                        // 친구 요청리스트
                                        buildFriendRequestList((AppLocalizations.of(context).tr('tabNavigation.friend.friendRequest')), requestList),

                                        // 친구 리스트
                                        buildFriendList((AppLocalizations.of(context).tr('tabNavigation.friend.friendList')), friendList)

                                    ],
                                ),
                            ),
                        ],
                    ),
                    // Loding
                    isLoading ? Loading() : Container()
                ]
            ),
            onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
            },
        );
    }

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구 검색 부분 위젯
    */
    Widget buildSearch() {
        return Container(
            color: Color.fromRGBO(255, 255, 255, 1),
            child:Container(
                width: ScreenUtil().setWidth(343),
                height: ScreenUtil().setHeight(36),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtil().setHeight(8)),
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                ),
                margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16.0),
                    vertical: ScreenUtil().setHeight(6),
                ),
                child: TextFormField(
                    controller: searchController,
                    maxLines: 1,
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        fontSize: ScreenUtil().setSp(15),
                        letterSpacing: ScreenUtil().setWidth(-0.75),
                        color: Color.fromRGBO(39, 39, 39, 1),
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            top: sameSize * 9,
                            bottom: sameSize * 11,
                            left: ScreenUtil().setWidth(7)
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                            Icons.search,
                            color: Color.fromRGBO(39, 39, 39, 0.5),
                        ),
                        hintText: (AppLocalizations.of(context).tr('tabNavigation.friend.search')),
                        hintStyle: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(15),
                            letterSpacing: ScreenUtil().setWidth(-0.75),
                            color: Color.fromRGBO(39, 39, 39, 0.4),
                        ),
                        suffixIcon: searchController.text != "" ? IconButton(
                            icon: Image.asset("assets/images/icon/iconDeleteSmall.png"),
                            onPressed: () => searchController.clear(),
                        ) : null,
                    ),
                ),
            )
        );
    }

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구 요청 부분 위젯
    */
    Widget buildFriendRequestList(String title, List<dynamic> friendInfoList)  {
        return Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)),
                    bottom: BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1))
                )
            ),
            child: Column(
                children: <Widget>[
                    InkWell(
                        child:Container(
                            width: ScreenUtil().setWidth(375),
                            height: ScreenUtil().setHeight(29),
                            color: Color.fromRGBO(255, 255, 255, 1),
                            child: Row(
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(375),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: ScreenUtil().setWidth(16)
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                                Container(
                                                    child: Row(
                                                        children: <Widget>[
                                                            Text(
                                                                title,
                                                                style: TextStyle(
                                                                    fontFamily: "NotoSans",
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: ScreenUtil().setSp(13),
                                                                    letterSpacing: ScreenUtil().setWidth(-0.65),
                                                                    color: Color.fromRGBO(39, 39, 39, 1),
                                                                ),
                                                            ),
                                                            Padding(
                                                                padding: EdgeInsets.only(
                                                                    left: ScreenUtil().setWidth(5)
                                                                ),
                                                                child: Text(
                                                                    friendInfoList.length.toString(),
                                                                    style: TextStyle(
                                                                        fontFamily: "NotoSans",
                                                                        fontWeight: FontWeight.w500,
                                                                        fontSize: ScreenUtil().setSp(13),
                                                                        letterSpacing: ScreenUtil().setWidth(-0.65),
                                                                        color: Color.fromRGBO(39, 39, 39, 0.4),
                                                                    ),
                                                                ),
                                                            ),
                                                            friendInfoList.length != 0 ? Padding(
                                                                padding: EdgeInsets.only(
                                                                    left: ScreenUtil().setWidth(5)
                                                                ),
                                                                child: Container(
                                                                    width: ScreenUtil().setWidth(6.5),
                                                                    height: ScreenUtil().setHeight(6.5),
                                                                    decoration: BoxDecoration(
                                                                        color: Color.fromRGBO(76, 96, 191, 1),
                                                                        borderRadius: new BorderRadius.circular(
                                                                            ScreenUtil().setWidth(10)
                                                                        ),
                                                                    ),
                                                                )
                                                            ): Container()
                                                        ],
                                                    )
                                                ),
                                                requestExpandFlag ?
                                                Image.asset('assets/images/icon/iconFold.png')
                                                    :Image.asset('assets/images/icon/iconUnfold.png')
                                            ],
                                        )
                                    )
                                ],
                            )
                        ),
                        onTap: (){
                            toggleExpand();
                        },
                    ),

                    ///Expand Friend request
                    friendInfoList.length == 0 ?
                        ///친구요청 없을때
                    AnimatedSize(
                        curve: Curves.ease,
                        vsync: this, duration: new Duration(milliseconds: 500),
                        child:  Container(
                            color: Color.fromRGBO(250, 250, 250, 1),
                            height:ScreenUtil().setHeight(requestListHeight - 31),
                            child: Center(
                                child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        Text(
                                            (AppLocalizations.of(context).tr('tabNavigation.friend.noNewRequest')),
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: ScreenUtil().setSp(14),
                                                letterSpacing: ScreenUtil().setWidth(-0.65),
                                                color: Color.fromRGBO(107, 107, 107, 1),
                                            ),
                                        )
                                    ]
                                )
                            )
                        )
                    )
                        ///친구요청 있을때
                    : MediaQuery.removePadding(
                        removeTop: true,
                        child: ListView.builder(
                            physics: new NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: friendInfoList.length,
                            itemBuilder: (BuildContext context, int index) => buildFriendItem(friendInfoList[index], false, index == friendInfoList.length - 1, index)
                        ),
                        context: context,
                    )
                ],
            ),
        );
    }

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구 목록 부분 위젯
    */
    Widget buildFriendList(String title, List<dynamic> friendInfoList) {
        return MediaQuery.removePadding(
            child: ListView.builder(
                physics: new NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: friendInfoList.length,
                itemBuilder: (BuildContext context, int index) => buildFriendItem(friendInfoList[index], true, index == friendInfoList.length - 1, index)
            ),
            context: context,
        );
    }

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구 한명 구성 위젯
    */
    //TODO 한개일때 여러개일때 패딩 차이
    Widget buildFriendItem(dynamic friendInfo, bool isFriendList, bool isLast, int index) {
        String profileImgUri = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + friendInfo.user_idx.toString() + "&type=SMALL";
        return InkWell(
            child: AnimatedSize(
                curve: Curves.ease,
                vsync: this, duration: new Duration(milliseconds: 500),
                child: Container(
                    width: ScreenUtil().setWidth(375),
                    height: ScreenUtil().setHeight(
                        isFriendList ?
                        index == 0 ?
                        74
                            : 66
                            : requestListHeight - 31),
                    color: Color.fromRGBO(255, 255, 255, 1),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(16),
                        top : isFriendList && index == 0 ?  ScreenUtil().setHeight(8) : 0,
                        bottom: isLast && requestExpandFlag ? ScreenUtil().setHeight(4) : 0
                    ),
                    child: Row(
                        children: <Widget>[
                            // 유저 이미지
                            Container(
                                width: sameSize * 50,
                                height: sameSize * 50,
                                margin: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(6),
                                    bottom: ScreenUtil().setHeight(6),
                                ),
                                child: ClipRRect(
                                    borderRadius: new BorderRadius.circular(
                                        ScreenUtil().setWidth(300)
                                    ),
                                    child: CachedNetworkImage(
                                        imageUrl: profileImgUri,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Image.asset('assets/images/icon/profile.png',fit: BoxFit.cover),
                                        httpHeaders: Constant.HEADER
                                    )
                                )
                            ),
                            // 유저 정보
                            Container(
                                width: ScreenUtil().setWidth(293),
                                height: ScreenUtil().setHeight(62),
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(13.5),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Text(
                                                    friendInfo.nickname,
                                                    style: TextStyle(
                                                        height: 1,
                                                        fontFamily: "NotoSans",
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: ScreenUtil().setSp(16),
                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                        letterSpacing: ScreenUtil()
                                                            .setWidth(-0.8),
                                                    ),
                                                ),
                                                !isFriendList ? Container(
                                                    width: ScreenUtil().setWidth(159),
                                                    child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top: ScreenUtil().setHeight(8)
                                                        ),
                                                        child:  Text(
                                                            friendInfo.description.toString() == 'null' ?
                                                            '안녕하세요! ' + friendInfo.nickname + "입니다! :)"
                                                                : friendInfo.description.toString(),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                fontFamily: "NotoSans",
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: ScreenUtil().setSp(14),
                                                                color: Color.fromRGBO(107, 107, 107, 1),
                                                                letterSpacing: ScreenUtil().setWidth(-0.8),
                                                            ),
                                                        ),
                                                    ),
                                                ) : Container()
                                            ],
                                        ),
                                        !isFriendList
                                            ? Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                                Container(),
                                                friendBtn(0, friendInfo, index),
                                                friendBtn(1, friendInfo, index),
                                            ],
                                        ): Container()
                                    ],
                                ),
                            )
                        ],
                    )
                )
            ),
            onTap: () {
                _showModalSheet(context, friendInfo);
            },

        );
    }

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구 수락, 삭제 위젯(index 0 - 수락, 1 - 거절)
    */
    Widget friendBtn(int index, dynamic friendInfo, int listIdx) {
        Color tabColor = index == 0 ? Color(0xffeaeaea) : Color.fromRGBO(77, 96, 191, 1);
        Color textColor = index == 0 ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(255, 255, 255, 1);

        return new InkWell(
            child: Container(
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setWidth(32),
                margin: EdgeInsets.only(
                    left: index == 0 ? ScreenUtil().setWidth(10) : ScreenUtil().setWidth(8),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(10.5))
                    ),
                    color: tabColor
                ),
                child: Center (
                    child: Text(
                        index == 0 ? (AppLocalizations.of(context).tr('tabNavigation.friend.delete')) : (AppLocalizations.of(context).tr('tabNavigation.friend.accept')),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(14),
                            color: textColor
                        ),
                    ),
                ),
            ),
            onTap: (){
                if(index == 0){
                    rejectRequest(friendInfo, listIdx);
                } else {
                    approveRequest(friendInfo, listIdx);
                }
            },
        );

    }

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 연락처 유무 아이콘 위젯
    */
    Widget contactIcon = new Container(
        width: ScreenUtil().setWidth(20),
        height: ScreenUtil().setHeight(20),
        margin: EdgeInsets.only(
            right: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconAddress.png")
            ),
        )
    );

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 유저 프로필 하단 모달 위젯
    */
    Widget userProfileModal(BuildContext context, dynamic friendInfo ,StateSetter setStateBuild) {
        return Container(
            height: friendInfo.user_idx == Constant.USER_IDX ? ScreenUtil().setHeight(200) : ScreenUtil().setHeight(299),
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
                                        friendInfo.nickname,
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
                        height: friendInfo.user_idx == Constant.USER_IDX ? ScreenUtil().setHeight(148) : ScreenUtil().setHeight(246),
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
                                                    Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + friendInfo.user_idx.toString() + "&type=BIG"
                                                    , scale: 1
                                                    , headers: Constant.HEADER
                                                ),
                                                fit: BoxFit.cover,
                                                fadeInDuration: Duration(milliseconds: 1)
                                            )
                                        )
                                    ),
                                    onTap: () {
                                        if(Provider.of<UserInfoProvider>(context, listen: false).cacheProfileImg.errorWidget == null){
                                            Navigator.push(
                                                context, MaterialPageRoute(
                                                builder: (context) =>
                                                    FullPhoto(
	                                                    photoUrl: Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + friendInfo.user_idx.toString() + "&type=BIG"
                                                    )
                                            ));
                                        }
                                    },
                                ),
                                Container(
                                    child: Text(
                                        // TODO: 인삿말 맵핑
                                        friendInfo.description.toString() == 'null' ?
                                            '안녕하세요! ' + friendInfo.nickname + "입니다! :)"
                                            : friendInfo.description.toString(),
                                        style: TextStyle(
                                            height: 1,
                                            fontSize: ScreenUtil().setSp(13),
                                            letterSpacing: ScreenUtil().setWidth(-0.33),
                                            color: Color.fromRGBO(107, 107, 107, 1)
                                        ),
                                    )
                                ),
                                friendInfo.user_idx == Constant.USER_IDX ? Container() : Container(
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
                                            userFunc(
                                                "assets/images/icon/iconDirectChat.png"
                                                ,AppLocalizations.of(context).tr('tabNavigation.friend.personalChat')
                                                ,_createChat, friendInfo, setStateBuild),
                                            userFunc(
                                                "assets/images/icon/iconBlock.png"
                                                , AppLocalizations.of(context).tr('tabNavigation.friend.block')
                                                , null, friendInfo, setStateBuild)
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

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 유저 프로필 각 기능 모달 (1:1채팅, 차단하기)
    */
    Widget userFunc(String iconSrc, String title,Function fn, dynamic friendInfo, StateSetter setStateBuild) {
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
                            fn(friendInfo);
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
