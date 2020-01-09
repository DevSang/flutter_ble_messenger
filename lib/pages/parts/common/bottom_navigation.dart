import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/pages/tab/chat_tab.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:Hwa/pages/tab/hwa_tab.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/pages/profile/profile_page.dart';
import 'package:Hwa/pages/trend/trend_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/data/state/user_info_provider.dart';


final hwaTabStateKey = new GlobalKey<HwaTabState>();

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-06
 * @description : Bottom Navigation Bar
 */
class BottomNavigation extends StatefulWidget implements PreferredSizeWidget {
    final int activeIndex;
    BottomNavigation({Key key,this.activeIndex}) : super(key: key);

    @override
    Size get preferredSize => Size(375, 84);

    @override
    _BottomNavigationState createState() => new _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>{
	UserInfoProvider userInfoProvider;
	final List<Widget> list = <Widget>[];
    int _currentIndex;

    // 화면 비율에 따른 1:1 요소 사이즈 셋팅
    double sameSize;

    String appBarTitle = "";

    @override
    void initState() {
		_currentIndex = widget.activeIndex ?? 0;

        list
            ..add(HwaTab(key: hwaTabStateKey))
            ..add(FriendTab())
            ..add(new ChatTab( setCurrentIndex:setCurrentIndex));

        sameSize  = GetSameSize().main();

        super.initState();
    }

    /*
    * @author : sh
    * @date : 2020-01-01
    * @description : bottom navigation
    */
    setCurrentIndex(int index) {
        setState(() {
            _currentIndex = index;
        });
    }

    displayDialog(){
		hwaTabStateKey.currentState.displayDialog();
    }

    /*
     * @author : hk
     * @date : 2020-01-02
     * @description : 사용자 이미지 캐시 실패시 다음부터 기본 Asset 이미지 제공
     */
    getErrorWidget(){
	    Constant.APP_BAR_LOADING_ERROR = true;
	    return Image.asset('assets/images/icon/profile.png');
    }

    /*
     * @author : hk
     * @date : 2020-01-06
     * @description : appBar title 설정
     */
    getAppBarTitle(context){
    	if(_currentIndex == 0) return AppLocalizations.of(context).tr('tapMenuTitle.hwa');
    	if(_currentIndex == 1) return AppLocalizations.of(context).tr('tapMenuTitle.friend');
    	if(_currentIndex == 2) return AppLocalizations.of(context).tr('tapMenuTitle.chat');
    }

    @override
    Widget build(BuildContext context) {
	    sameSize  = GetSameSize().main();

        return Scaffold(
	        appBar: PreferredSize(
		        preferredSize: widget.preferredSize,
		        child: SafeArea(
			        child: Container(
				        width: ScreenUtil().setWidth(375),
				        height: ScreenUtil().setHeight(61.5),
				        decoration: BoxDecoration(
						        color: Color.fromRGBO(255, 255, 255, 1),
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
													        getAppBarTitle(context),
													        style: TextStyle(
														        height: 1,
														        fontFamily: "NotoSans",
														        fontWeight: FontWeight.w700,
														        fontSize: ScreenUtil(allowFontScaling: true).setSp(20),
														        color: Color.fromRGBO(39, 39, 39, 1),
														        letterSpacing: ScreenUtil().setWidth(-0.5),
													        ),
												        ),
											        ),
											        _currentIndex == 0
                                                        ? getLeftChild()
                                                        : Container(
                                                            height: sameSize * 22,
                                                        )
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
														        shape: BoxShape.circle
												        ),
												        child: ClipRRect(
														        borderRadius: new BorderRadius.circular(ScreenUtil().setHeight(45)),
														        child: Provider.of<UserInfoProvider>(context).getUserProfileImg()
												        ),
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
//														        expireProfileImgCache()
									        });
								        },
							        )
						        ),
					        ],
				        )
			        )
		        )
	        ),
            body: list[_currentIndex],
            bottomNavigationBar: Theme(
                data: Theme.of(context).copyWith(
                // sets the background color of the `BottomNavigationBar`
                    canvasColor: Color.fromRGBO(255, 255, 255, 1)
                ),
                child: new BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (int index){
                        setState(() {
                            _currentIndex = index;
                        });
                    },
                    selectedItemColor: Color.fromRGBO(77, 96, 191, 1),
                    selectedLabelStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(10),
                        letterSpacing: ScreenUtil().setWidth(-0.25),
                    ),
                    unselectedItemColor: Color.fromRGBO(0, 0, 0, 0.4),
                    unselectedLabelStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(10),
                        letterSpacing: ScreenUtil().setWidth(-0.25),
                    ),
                    type: BottomNavigationBarType.fixed,
                    items: [
                        BottomNavigationBarItem(
                            icon: _currentIndex == 0
                                    ? Image.asset('assets/images/icon/tabIconHwaActive.png')
                                    : Image.asset('assets/images/icon/tabIconHwa.png'),
                            title: Text ('HWA')
                        ),
                        BottomNavigationBarItem(
                            icon: _currentIndex == 1 ? Image.asset('assets/images/icon/tabIconFriendActive.png') : Image.asset('assets/images/icon/tabIconFriend.png'),
                            title: Text ('Friend')
                        ),
                        BottomNavigationBarItem(
                            icon: _currentIndex == 2 ? Image.asset('assets/images/icon/tabIconChatActive.png') : Image.asset('assets/images/icon/tabIconChat.png'),
                            title: Text ('Chat')
                        ),
                        //            BottomNavigationBarItem(
                        //                icon: _currentIndex == 4 ? Image.asset('assets/images/icon/tabIconChatActive.png') : Image.asset('assets/images/icon/tabIconChat.png'),
                        //                title: Text ('test')
                        //            )
                    ]
                ),
            ),
            backgroundColor: Color.fromRGBO(255, 255, 255, 1)
        );
    }

    /*
     * @author : hk
     * @date : 2020-01-06
     * @description : appBar title 오른쪽 트렌드, 단화방 만들기 버튼, TODO hidden으로 처리?
     */
    Widget getLeftChild(){
    	return Row(
		    children: <Widget>[
			    Container(
				    width: sameSize * 22,
				    height: sameSize * 22,
				    margin: EdgeInsets.only(left: 16),

				    child: InkWell(
					    child: Image.asset('assets/images/icon/navIconHot.png'),
					    onTap: () =>
							    Navigator.push(
									    context, MaterialPageRoute(
									    builder: (context) => TrendPage())),
				    )
			    ),
			    Container(
				    margin: EdgeInsets.only(left: 16),
				    width: sameSize * 22,
				    height: sameSize * 22,
				    child: InkWell(
					    child: Image.asset(
							    'assets/images/icon/navIconNew.png'),
					    onTap: (){
						    displayDialog();
					    }
				    )
			    ),
		    ],
	    );
    }
}