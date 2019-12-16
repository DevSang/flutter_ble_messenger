import 'package:flutter/material.dart';
import 'package:Hwa/pages/trend_page.dart';

class HwaTab extends StatefulWidget {
  @override
  _HwaTabState createState() => _HwaTabState();
}

class _HwaTabState extends State<HwaTab> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       appBar: AppBar(
         backgroundColor: Colors.white,
         title: Text("단화방", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans')
         ),
         actions: <Widget>[
           IconButton(
             icon: Image.asset('assets/images/icon/navIconHot.png'),
             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TrendPage())),
             padding: EdgeInsets.only(right: 16),
           ),
           IconButton(
             icon: Image.asset('assets/images/icon/navIconNew.png'),
             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TrendPage())),
             padding: EdgeInsets.only(right: 16),

           )
         ],
       ),
           body: Center (child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[

                 SizedBox(
                   width: 25.0,
                   height: 25.0,
                   child: FloatingActionButton(
                        child : Image.asset('assets/images/icon/iconPin.png'),
                   onPressed: () {}
                   ),
                 ),
                 InkWell(
                   child: Text('현재 위치', style: TextStyle(fontSize: 13, color: Colors.black54),  ),
                 ),

                 InkWell(
                   child: Text('서초대로 78 180', style: TextStyle(fontSize: 15, color: Colors.black),  ),
                 ),


               ],
           ),
     ),
     );
  }


}


