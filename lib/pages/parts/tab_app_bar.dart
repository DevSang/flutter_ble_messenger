import 'dart:convert';

import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kvsql/kvsql.dart';

import '../profile_page.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-30
 * @description : Custom App Bar
 */
class TabAppBar extends StatefulWidget implements PreferredSizeWidget {
    final String title;
    final Widget leftChild;

    @override
    Size get preferredSize => Size(375, 84);
    TabAppBar({@required this.title, this.leftChild});

    @override
    TabAppBarState createState() => TabAppBarState(title: title, leftChild: leftChild);
}

class TabAppBarState extends State<TabAppBar> {
    final String title;
    final Widget leftChild;
    SharedPreferences SPF;
    Map userInfo;
    double sameSize;

    // 로그아웃 key/value 지우기 위함
    SharedPreferences prefs;
    final store = KvStore();

    TabAppBarState({@required this.title, this.leftChild});

    CachedNetworkImageProvider profileImg;

    @override
    void initState() {
	    setUserInfo();
	    _initState();
        super.initState();
    }

    void _initState() async {
	    profileImg = CachedNetworkImageProvider(Constant.PROFILE_IMG_URI, headers: Constant.HEADER);
    }

    /*
     * @author : hk
     * @date : 2020-01-02
     * @description : 프로필 이미지 변경됐을 경우 캐시 지우고 새로 로딩
     */
    void expireProfileImgCache() async {
	    if(Constant.IS_CHANGE_PROFILE_IMG){
		    profileImg.evict();
		    profileImg = CachedNetworkImageProvider(Constant.PROFILE_IMG_URI, headers: Constant.HEADER);
	    }
    }

    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 임시 로그아웃
    */
    Future<void> logOut() async {
        SPF = await SharedPreferences.getInstance();
        await store.onReady;
        prefs.remove('token');
        store.delete("friendList");
        store.delete("test");

        return;
    }

    /*
    * @author : sh
    * @date : 2019-12-30
    * @description : Set user info
    */
    void setUserInfo () async {
        SharedPreferences SPF = await SharedPreferences.getInstance();
        setState(() {
            userInfo = jsonDecode(SPF.getString('userInfo'));
        });
    }

    /*
    * @author : sh
    * @date : 2019-12-30
    * @description : top app bar위
    */
    Widget build(BuildContext context) {
        sameSize  = GetSameSize().main();
        return PreferredSize(
            preferredSize: widget.preferredSize,
            child: SafeArea(
                child: Container(
                    width: ScreenUtil().setWidth(375),
                    height: ScreenUtil().setHeight(61.5),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(250, 250, 250, 1),
                        boxShadow: [
                            new BoxShadow(
                                color: Color.fromRGBO(178, 178, 178, 0.8),
                                offset: new Offset(ScreenUtil().setWidth(0), ScreenUtil().setWidth(0.5)),
                                blurRadius: ScreenUtil().setWidth(0)
                            )
                        ]
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            Container(
                                height: ScreenUtil().setHeight(56.5),
                                margin: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(16),
                                ),
                                child: Row(
                                    children: <Widget>[
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                                Container(
                                                    child: Text(
                                                        title,
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: ScreenUtil(allowFontScaling: true).setSp(20),
                                                            color: Color.fromRGBO(39, 39, 39, 1),
                                                            letterSpacing: ScreenUtil().setWidth(-0.5),
                                                        ),
                                                    ),
                                                ),
                                                leftChild
                                            ],
                                        ),
                                    ],
                                )
                            ),
                            Container(
                                width: ScreenUtil().setHeight(60.5),
                                height: ScreenUtil().setHeight(56.5),
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(8),
                                    right: ScreenUtil().setWidth(8),
                                    top: ScreenUtil().setHeight(8),
                                    bottom: ScreenUtil().setHeight(8.5),
                                ),
                                margin: EdgeInsets.only(
                                    right: ScreenUtil().setWidth(7.5),
                                ),
                                child: InkWell(
                                    child: Stack(
                                        children: <Widget>[
                                            Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                    width: ScreenUtil().setHeight(38),
                                                    height: ScreenUtil().setHeight(38),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
//                                                            image: CachedNetworkImageProvider(Constant.PROFILE_IMG_URI, headers: Constant.HEADER),
                                                            image: profileImg,
//		                                                        image: isLoadingComplete
//		                                                            ? CachedNetworkImageProvider(Constant.PROFILE_IMG_URI, headers: Constant.HEADER)
//		                                                            : AssetImage("assets/images/icon/profile.png"),
                                                            fit: BoxFit.cover
                                                        ),
                                                        shape: BoxShape.circle
                                                    )
                                                ),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                left: 0,
                                                child: GestureDetector(
                                                    child: Container(
                                                        width: ScreenUtil().setHeight(21.5),
                                                        height: ScreenUtil().setHeight(21.5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            image: DecorationImage(
                                                                image:AssetImage("assets/images/icon/setIcon.png"),
                                                                fit: BoxFit.cover
                                                            ),
                                                            shape: BoxShape.circle,
                                                        )
                                                    )
                                                )
                                            ),
                                        ],
                                    ),
                                    onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) {
                                                return ProfilePage();
                                            })
                                        ).then((val) => {
	                                        expireProfileImgCache()
                                        });
                                    },
                                )
                            ),
                        ],
                    )
                )
            )
        );
    }
}