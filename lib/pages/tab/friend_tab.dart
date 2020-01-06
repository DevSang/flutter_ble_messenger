import 'dart:developer' as developer;
import 'dart:convert';

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/package/fullPhoto.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kvsql/kvsql.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/data/models/friend_request_info.dart';
import 'package:Hwa/pages/parts/friend/set_friend_data.dart';
import 'package:Hwa/pages/parts/common/tab_app_bar.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/home.dart';

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
    _FriendTabState createState() => _FriendTabState();
}

class _FriendTabState extends State<FriendTab> {
    final store = KvStore();

//    List<FriendInfo> friendList = Constant.FRIEND_LIST ?? <FriendInfo>[];
    List<FriendInfo> originList;              // 원본 친구 리스트
    List<FriendInfo> friendList;              // 화면에 보이는 친구 리스트 (검색 용도)
    List<FriendRequestInfo> requestList = [];

    TextEditingController searchController = TextEditingController();
    double sameSize;
    bool isLoading;

    ScrollController _scrollController;

    @override
    void initState() {
        _initState();

        _scrollController = new ScrollController()..addListener(_sc);
        sameSize = GetSameSize().main();
        isLoading = false;

        super.initState();
    }

    /*
     * @author :sh
     * @date : 2020-01-01
     * @description : 친구리스트 초기화
     */
    void _initState() async {
//        friendList = Constant.FRIEND_LIST;
//        originList = Constant.FRIEND_LIST;

        await getFriendList();
        await getFriendRequestList();

        friendList.sort((a, b) => a.nickname.compareTo(b.nickname));
    }

    @override
    void dispose() {
        super.dispose();
    }

    void _sc() {
        developer.log(_scrollController.position.extentAfter.toString());
        if (_scrollController.position.extentAfter < 500) {
            setState(() {
                new List.generate(42, (index) => 'Inserted $index');
            });
        }
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
            friendList.addAll(constList);
        });
    }

    /*
     * @author : hs
     * @date : 2020-01-02
     * @description : 친구목록 호출
    */
    getFriendList() async {
        originList = [];
        friendList = [];
        List<FriendInfo> getFriendList = <FriendInfo>[];

        String uri = "/api/v2/relation/relationship/all";
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);
        if(response.body != null){
            List<dynamic> friendListJson = jsonDecode(response.body)['data'];

            for(var i = 0; i < friendListJson.length; i++){
                var friendInfo = friendListJson[i]['related_user_data'];
                getFriendList.add(
                    FriendInfo(
                        user_idx: friendInfo['user_idx'],
                        nickname: friendInfo['nickname'],
                        phone_number: friendInfo['phone_number'],
                        profile_picture_idx: friendInfo['profile_picture_idx'],
                        business_card_idx: friendInfo['business_card_idx'],
                        user_status: friendInfo['user_status']
                    )
                );
            }
            setState(() {
                originList.addAll(getFriendList);
                friendList.addAll(getFriendList);
            });
//            await store.put<List<FriendInfo>>("friendRequestList",friendRequestList);
        } else {
            setState(() {
                originList = [];
                friendList = [];
            });

//            await store.put<List<FriendInfo>>("friendRequestList",[]);
        }
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 친구요청 목록
    */
    getFriendRequestList () async {
        List<FriendRequestInfo> friendRequestList = <FriendRequestInfo>[];

        String uri = "/api/v2/relation/request/all";
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);
        if(response.body != null){
            List<dynamic> friendRequest = jsonDecode(response.body)['data'];

            for(var i = 0; i < friendRequest.length; i++){
                var friendInfo = friendRequest[i]['jb_request_user_data'];
                if(!['5101','5102'].contains(friendRequest[i]['response_type']) && !friendRequest[i]['is_cancel']){
                    friendRequestList.add(
                        FriendRequestInfo(
                            req_idx: friendRequest[i]['idx'],
                            user_idx: friendInfo['user_idx'],
                            nickname: friendInfo['nickname'],
                            phone_number: friendInfo['phone_number'],
                            profile_picture_idx: friendInfo['profile_picture_idx'],
                            business_card_idx: friendInfo['business_card_idx'],
                            user_status: friendInfo['user_status']
                        )
                    );
                }
            }
            setState(() {
                requestList = friendRequestList;
            });
//            await store.put<List<FriendInfo>>("friendRequestList",friendRequestList);
        } else {
            setState(() {
                requestList = [];
            });

//            await store.put<List<FriendInfo>>("friendRequestList",[]);
        }
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
            friendList.add(
                FriendInfo(
                    user_idx: friendInfo.user_idx,
                    nickname: friendInfo.nickname,
                    phone_number: friendInfo.phone_number,
                    profile_picture_idx: friendInfo.profile_picture_idx,
                    business_card_idx: friendInfo.business_card_idx,
                    user_status: friendInfo.user_status
                )
            );
            requestList.removeAt(listIdx);
            _initState();
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
            requestList.removeAt(listIdx);
            _initState();
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
    _showModalSheet(BuildContext context, FriendInfo friendInfo) {
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

            developer.log("################" + chatInfo.toString());
            developer.log("################**" + isLiked.toString());
            developer.log("################**" + friendInfo.user_idx.toString());
            developer.log("################**" + friendInfo.nickname);

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


    @override
    Widget build(BuildContext context) {
        searchController.addListener(() {
            searchFriends();
        });

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                appBar: TabAppBar(
                    title: '단화 친구',
                    leftChild: Container(
                        margin: EdgeInsets.only(
                            left: 8
                        ),
                        child: Row(
                            children: <Widget>[
                                Text(
                                    friendList != null ? friendList.length.toString() : 0.toString(),
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NanumSquare",
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenUtil(
                                            allowFontScaling: true).setSp(13),
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        letterSpacing: ScreenUtil().setWidth(
                                            -0.33),
                                    ),
                                ),
                                Text(
                                    "명",
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenUtil(
                                            allowFontScaling: true).setSp(13),
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        letterSpacing: ScreenUtil().setWidth(
                                            -0.33),
                                    ),
                                ),
                            ],
                        )
                    ),
                ),
                body: buildBody(),
                resizeToAvoidBottomPadding: false,
            )
        );
    }

    Widget buildBody() {
        return Stack(
            children: <Widget>[
                Column(
                    children: <Widget>[
                        // 친구 검색
                        buildSearch(),
                        Flexible(
                            child: ListView(
                                children: <Widget>[
                                    // 친구 요청리스트
                                    buildFriendList('친구 요청', requestList, false),

                                    // 친구 리스트
                                    buildFriendList('친구 목록', friendList, true)

                                ],
                            ),
                        ),
                    ],
                ),

                // Loading
                isLoading ? Loading() : Container()
            ]
        );
    }

    Widget buildSearch() {
        return Container(
            width: ScreenUtil().setWidth(343),
            height: ScreenUtil().setHeight(36),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setHeight(18)),
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
                        left: ScreenUtil().setWidth(7),
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                        Icons.search,
                        color: Color.fromRGBO(39, 39, 39, 0.5),
                    ),
                    hintText: "검색",
                    hintStyle: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        fontSize: ScreenUtil().setSp(15),
                        letterSpacing: ScreenUtil().setWidth(-0.75),
                        color: Color.fromRGBO(39, 39, 39, 0.4),
                    ),
                ),
            ),
        );
    }

    Widget buildFriendList(String title, List<dynamic> friendInfoList, bool isFriend) {
        return Container(
            child: Column(
                children: <Widget>[
                    Container(
                        width: ScreenUtil().setWidth(375),
                        height: ScreenUtil().setHeight(30),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(214, 214, 214, 1),
                        ),
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(10),
                        ),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                                children: <Widget>[
                                    Container(
                                        width: sameSize*30,
                                        margin: EdgeInsets.only(
                                            right: ScreenUtil().setWidth(8)
                                        ),
                                        child: Image.asset(
                                            title == '친구 목록'
                                                ?'assets/images/icon/iconMasterBadge.png'
                                                : 'assets/images/icon/iconAttachMore.png'
                                                ,
                                            fit: BoxFit.fitWidth,
                                        )
                                    )
                                    ,Text(
                                        title,
                                        style: TextStyle(
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w400,
                                            fontSize: ScreenUtil().setSp(13),
                                            letterSpacing: ScreenUtil().setWidth(-0.65),
                                            color: Color.fromRGBO(39, 39, 39, 1),
                                        ),
                                    )
                                ],
                            )
                        )
                    ),
                    friendInfoList.length == 0 ?
                        Column(
                            children: <Widget>[
                                Container(
                                    height: title == '친구 목록' ? ScreenUtil().setHeight( (5 - requestList.length) * 62 ) : ScreenUtil().setHeight(62),
                                    child: Center(
                                        child:Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                                Text(
                                                    title == '친구 목록' ? "아직 추가된 친구가 없어요." : "새로운 친구 요청이 없어요.",
                                                    style: TextStyle(
                                                        fontFamily: "NotoSans",
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: ScreenUtil().setSp(14),
                                                        letterSpacing: ScreenUtil().setWidth(-0.65),
                                                        color: Color.fromRGBO(39, 39, 39, 0.2),
                                                    ),
                                                ),
                                                title == '친구 목록' ? Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: <Widget>[
                                                        Image.asset(
                                                            'assets/images/icon/appIcon2.png',
                                                            width: ScreenUtil().setWidth(50),
                                                            height: ScreenUtil().setHeight(50),
                                                        )
                                                    ],
                                                ) : Container()
                                            ]
                                        )
                                    )
                                ),
                            ],
                        )

                        : ListView.builder(
                            physics: new NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: friendInfoList.length,
                            itemBuilder: (BuildContext context, int index) => buildFriendItem(friendInfoList[index], isFriend, index == friendInfoList.length - 1, index)
                        )
                ],
            ),
        );
    }


    Widget buildFriendItem(dynamic friendInfo, bool isFriend, bool isLast, int index) {
        developer.log("friendInfo" + friendInfo.user_idx.toString());
        String profileImgUri = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + friendInfo.user_idx.toString() + "&type=SMALL";
        return InkWell(
            child: Container(
                width: ScreenUtil().setWidth(375),
                height: ScreenUtil().setHeight(62),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(16)
                ),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(250, 250, 250, 1),
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
                            height: isLast ? ScreenUtil().setHeight(61) : ScreenUtil().setHeight(62),
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(13.5),
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: isLast ? 0 : sameSize,
                                        color: isLast ? Colors.white : Color.fromRGBO(39, 39, 39, 0.15)
                                    )
                                )
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            friendInfo.nickname,
                                            style: TextStyle(
                                                height: 1,
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w500,
                                                fontSize: ScreenUtil(allowFontScaling: true).setSp(16),
                                                color: Color.fromRGBO(39, 39, 39, 1),
                                                letterSpacing: ScreenUtil()
                                                    .setWidth(-0.8),
                                            ),
                                        )
                                    ),
                                    !isFriend
                                        ? Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                                Container(),
                                                friendBtn(0, friendInfo, index),
                                                friendBtn(1, friendInfo, index),
                                            ],
                                        )
                                        //TODO 주소록에 있는지 없는지
    //                                    : contactIcon
                                        : Container()
                                ],
                            ),
                        )
                    ],
                )
            ),
            onTap: () {
                _showModalSheet(context, friendInfo);
            },
        );
    }

    Widget friendBtn(int index, dynamic friendInfo, int listIdx) {
        Color tabColor = index == 0 ? Color.fromRGBO(158, 158, 158, 1) : Color.fromRGBO(77, 96, 191, 1);
        Color textColor = index == 0 ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(77, 96, 191, 1);

        return new InkWell(
            child: Container(
                width: ScreenUtil().setWidth(58),
                height: ScreenUtil().setWidth(32),
                margin: EdgeInsets.only(
                    left: index == 0 ? ScreenUtil().setWidth(10) : ScreenUtil().setWidth(8),
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: ScreenUtil().setWidth(1),
                        color: tabColor,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setHeight(16))
                    )
                ),
                child: Center (
                    child: Text(
                        index == 0 ? '삭제' : '수락',
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

    Widget userProfileModal(BuildContext context, FriendInfo friendInfo ,StateSetter setStateBuild) {
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
                                        Navigator.push(
                                            context, MaterialPageRoute(
                                            builder: (context) => FullPhoto(
                                                url: Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + friendInfo.user_idx.toString() + "&type=BIG"
                                                , header: Constant.HEADER
                                            )
                                        ));
                                    },
                                ),
                                Container(
                                    child: Text(
                                        // TODO: 인삿말 맵핑
//                                                userInfo.userIntro,
                                        '안녕하세요! ' + friendInfo.nickname + "입니다! :)",
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
                                            userFunc("assets/images/icon/iconDirectChat.png", "1:1 채팅", _createChat, friendInfo, setStateBuild),
                                            userFunc("assets/images/icon/iconBlock.png", "차단하기", null, friendInfo, setStateBuild)
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

    Widget userFunc(String iconSrc, String title,Function fn, FriendInfo friendInfo, StateSetter setStateBuild) {
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
//                            fn(userIdx, setStateBuild);
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
