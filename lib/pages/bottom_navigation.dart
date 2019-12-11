import 'package:flutter/material.dart';
import 'package:Hwa/pages/tab/chat_tab.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:Hwa/pages/tab/hwa_tab.dart';

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
      ..add(ChatTab());
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
                icon: Icon(Icons.home,color: Colors.black,),
                title: Text ('HWA', style: TextStyle (color: Colors. black))
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.contacts,color: Colors.black,),
                title: Text ('Friend', style: TextStyle (color: Colors. black))
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.find_in_page,color: Colors.black,),
                title: Text ('Chat', style: TextStyle (color: Colors. black))
            ),
          ]
      ),
    );
  }
}