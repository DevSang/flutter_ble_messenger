import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrendPage extends StatefulWidget {
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("실시간 단화 트렌드",
            style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'NotoSans'),
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          actions: <Widget>[
      IconButton(
      icon: Image.asset('assets/images/icon/navIconSearch.png'),
        padding: EdgeInsets.only(right: 16),
        onPressed: null,
    )
    ]
      ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 70,
          padding: EdgeInsets.only(top: 10, left: 10, right: 50, bottom: 10),
          child: Column(
            children: <Widget>[
              _searchTrend(),
              _noticeHeader(),
            ],
          ),
        )
      ],
    )


    );
  }

  Widget _searchTrend(){
    return Container(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[200]
            ),
            child: TextField (
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey,),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                hintText: "단화방 검색",
              ),
            ),
          ),
    );
  }


  Widget _noticeHeader() {
    return new Container(
        height: ScreenUtil().setHeight(80),
         padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(17),
          bottom: ScreenUtil().setHeight(14)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _headerTab(1),
            _headerTab(2),
            Container()
          ],
        )
    );
  }


  Widget _headerTab(int index) {
    Color tabColor = index == 1 ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(158, 158, 158, 1);
    Color textColor = index == 1 ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(107, 107, 107, 1);

    return  Container(
      width: ScreenUtil().setWidth(74),
      height: ScreenUtil().setHeight(36),
      margin: EdgeInsets.only(
        left: index == 2 ? ScreenUtil().setWidth(20) : 0,

      ),
      decoration: BoxDecoration(
          border: Border.all(
            width: ScreenUtil().setWidth(1),
            color: tabColor,
          ),
          borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil().setWidth(20))
          )
      ),
      child: Center (
        child: Text(
          index == 1 ? '공지' : '투표',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textColor
          ),
        ),
      ),
    );
  }
}