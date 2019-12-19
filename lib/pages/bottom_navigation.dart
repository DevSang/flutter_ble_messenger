import 'package:flutter/material.dart';
import 'package:Hwa/pages/tab/chat_tab.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:Hwa/pages/tab/hwa_tab.dart';
import 'package:Hwa/pages/chatroom_page.dart';

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
      ..add(ChatScreen());
    super.initState();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: list[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index){
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/icon/tabIconHwa.png'),
                title: Text ('HWA', style: TextStyle (color: Colors. black45))
            ),
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/icon/tabIconFriend.png'),
                title: Text ('Friend', style: TextStyle (color: Colors. black45))
            ),
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/icon/tabIconChat.png'),
                title: Text ('Chat', style: TextStyle (color: Colors. black45))
            ),
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/icon/tabIconChat.png'),
                title: Text ('Chatroom', style: TextStyle (color: Colors. black45))
            )
          ]
      ),
    );
  }
}