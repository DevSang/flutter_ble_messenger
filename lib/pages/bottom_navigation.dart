import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/pages/tab/chat_tab.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:Hwa/pages/tab/hwa_tab.dart';
import 'package:Hwa/pages/chatroom_page.dart';
import 'package:Hwa/pages/tab/test_tab.dart';
//바텀 네비게이션 바

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => new _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List<Widget> list = List();
  int _currentIndex = 0;
  @override
  void initState() {
    list
      ..add(HwaTab())
      ..add(FriendTab())
      ..add(ChatTab())
      ..add(ChatroomPage())
      ..add(ImageTest());

    super.initState();
}
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);
    return Scaffold(
      body: list[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
                icon: _currentIndex == 0 ? Image.asset('assets/images/icon/tabIconHwaActive.png') : Image.asset('assets/images/icon/tabIconHwa.png'),
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
            BottomNavigationBarItem(
                icon: _currentIndex == 3 ? Image.asset('assets/images/icon/tabIconChatActive.png') : Image.asset('assets/images/icon/tabIconChat.png'),
                title: Text ('Chatroom')
            ),
            BottomNavigationBarItem(
                icon: _currentIndex == 4 ? Image.asset('assets/images/icon/tabIconChatActive.png') : Image.asset('assets/images/icon/tabIconChat.png'),
                title: Text ('test')
            )
          ]
      ),
    );
  }
}