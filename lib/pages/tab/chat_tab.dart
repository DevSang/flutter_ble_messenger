import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/pages/parts/set_chat_list_data.dart';
import 'package:Hwa/pages/parts/tab_app_bar.dart';
class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  double sameSize;

  @override
  void initState() {
    super.initState();
    sameSize  = GetSameSize().main();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Colors.white,
        appBar: TabAppBar(
          title: '참여했던 단화방',
          leftChild: Container(
              height: 0
          ),
          rightChild: Container(),
        ),
    );
  }

}
