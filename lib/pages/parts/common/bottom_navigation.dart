import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:after_layout/after_layout.dart';

import 'package:Hwa/pages/tab/chat_tab.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:Hwa/pages/tab/hwa_tab.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/custom_dialog.dart';


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

class _BottomNavigationState extends State<BottomNavigation>{
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

    @override
    Widget build(BuildContext context) {
        return Scaffold(
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