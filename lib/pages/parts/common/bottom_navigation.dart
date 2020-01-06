import 'package:Hwa/pages/parts/common/tab_app_bar.dart';
import 'package:Hwa/pages/trend/trend_page.dart';
import 'package:Hwa/utility/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/pages/tab/chat_tab.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:Hwa/pages/tab/hwa_tab.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/tab/test_tab.dart';
import 'package:Hwa/utility/get_same_size.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-06
 * @description : Bottom Navigation Bar
 */
class BottomNavigation extends StatefulWidget {
    final int activeIndex;
    BottomNavigation({Key key,this.activeIndex}) : super(key: key);

    @override
    _BottomNavigationState createState() => new _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
    final List<Widget> list = <Widget>[];
    int _currentIndex;
    // 화면 비율에 따른 1:1 요소 사이즈 셋팅
    double sameSize;

    @override
    void initState() {
        _currentIndex = widget.activeIndex ?? 0;

        list
            ..add(HwaTab())
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

    /*
    * @author : hs
    * @date : 2019-12-27
    * @description : 단화방 생성 Dialog
    */
    void _displayDialog(BuildContext context) async {
//        return showDialog(
//            context: context,
//            builder: (BuildContext context) => CustomDialog(
//                title: '단화 생성하기',
//                type: 1,
//                leftButtonText: "취소",
//                rightButtonText: "생성하기",
//                value: _currentAddress,
//                hintText: _currentAddress == '위치 검색 중..'
//                    ? '단화방 이름을 입력해주세요.'
//                    : _currentAddress,
//                func: (String titleValue) {
//                    _createChat(titleValue);
//                    Navigator.of(context).pop();
//
//                    setState(() {
//                        isLoading = true;
//                    });
//                },
//                maxLength: 15,
//            ),
//        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: TabAppBar(
                title: "단화방",
                leftChild: Row(
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
                                    _displayDialog(context);
                                }
    //                                {
    //                                    if (Platform.isAndroid) {
    //                                        _displayAndroidDialog(context)
    //                                    } else if (Platform.isIOS) {
    //                                        _displayIosDialog(context)
    //                                    }
    //                                },
                            )
                        ),
                    ],
                ),
            ),
            body: list[_currentIndex],
            bottomNavigationBar: Theme(
                data: Theme.of(context).copyWith(
                // sets the background color of the `BottomNavigationBar`
                    canvasColor: Color.fromRGBO(250, 250, 250, 1)
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
            )
        );
    }

}