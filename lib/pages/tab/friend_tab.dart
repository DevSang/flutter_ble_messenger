import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/pages/parts/set_friend_data.dart';
import 'package:Hwa/pages/parts/tab_app_bar.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kvsql/kvsql.dart';
import 'package:cached_network_image/cached_network_image.dart';


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
    List<FriendInfo> originList = [];              // 원본 친구 리스트
    List<FriendInfo> friendList = [];                                   // 화면에 보이는 친구 리스트 (검색 용도)
    List<FriendInfo> requestList = [];

    TextEditingController searchController = TextEditingController();
    double sameSize;

    ScrollController _scrollController;

    @override
    void initState() {
        _scrollController = new ScrollController()..addListener(_sc);
        sameSize = GetSameSize().main();

        friendList.addAll(originList);
        friendList.sort((a, b) => a.nickname.compareTo(b.nickname));

        searchController.addListener(() {
            searchFriends();
        });

        _initState();

        super.initState();
    }

    /*
     * @author :sh
     * @date : 2020-01-01
     * @description : 친구리스트 초기화
     */
    void _initState() async {
        originList = Constant.FRIEND_LIST;
        requestList = Constant.FRIEND_REQUEST_LIST;

        print("originList" + originList.toString());
        print("requestList" + requestList.toString());
    }

    @override
    void dispose() {
        super.dispose();
    }

    void _sc() {
        print(_scrollController.position.extentAfter);
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

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                backgroundColor: Colors.white,
                appBar: TabAppBar(
                    title: '단화 친구',
                    leftChild: Container(
                        margin: EdgeInsets.only(
                            left: 8
                        ),
                        child: Row(
                            children: <Widget>[
                                Text(
                                    friendList.length.toString(),
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
        return Column(
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
                    contentPadding: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(7),
                        ScreenUtil().setHeight(11),
                        ScreenUtil().setWidth(13),
                        ScreenUtil().setHeight(11)
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

    Widget buildFriendList(String title, List<FriendInfo> friendInfoList, bool isFriend) {
        return Container(
            child: Column(
                children: <Widget>[
                    Container(
                        width: ScreenUtil().setWidth(375),
                        height: ScreenUtil().setHeight(25),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(214, 214, 214, 1),
                        ),
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(16),
                        ),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                title,
                                style: TextStyle(
                                    fontFamily: "NotoSans",
                                    fontWeight: FontWeight.w400,
                                    fontSize: ScreenUtil().setSp(13),
                                    letterSpacing: ScreenUtil().setWidth(-0.65),
                                    color: Color.fromRGBO(39, 39, 39, 1),
                                ),
                            )
                        )
                    ),
                    ListView.builder(
                        physics: new NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: friendInfoList.length,

                        itemBuilder: (BuildContext context, int index) => buildFriendItem(friendInfoList[index], isFriend, index == friendInfoList.length - 1)
                    )
                ],
            ),
        );
    }


    Widget buildFriendItem(FriendInfo friendInfo, bool isFriend, bool isLast) {
        print("friendInfo" + friendInfo.user_idx.toString());
        String profileImgUri = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + friendInfo.user_idx.toString() + "&type=SMALL";
        return Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(62),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16)
            ),
            decoration: BoxDecoration(
                color: Colors.white,
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
                                ScreenUtil().setWidth(10)
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
                            mainAxisAlignment: !isFriend ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        friendInfo.nickname,
                                        style: TextStyle(
                                            height: 1,
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight
                                                .w500,
                                            fontSize: ScreenUtil(
                                                allowFontScaling: true)
                                                .setSp(16),
                                            color: Color
                                                .fromRGBO(
                                                39, 39, 39, 1),
                                            letterSpacing: ScreenUtil()
                                                .setWidth(-0.8),
                                        ),
                                    )
                                ),
                                !isFriend
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            friendBtn(0),
                                            friendBtn(1),
                                            Container()
                                        ],
                                    )
                                    : contactIcon
                            ],
                        ),
                    )
                ],
            )
        );
    }

    Widget friendBtn(int index) {
        Color tabColor = index == 0 ? Color.fromRGBO(158, 158, 158, 1) : Color.fromRGBO(77, 96, 191, 1);
        Color textColor = index == 0 ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(77, 96, 191, 1);

        return new Container(
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
}
