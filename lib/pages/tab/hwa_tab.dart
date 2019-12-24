import 'package:flutter/material.dart';
import 'package:Hwa/pages/trend_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Hwa/data/models/chat_main.dart';
import 'package:Hwa/pages/profile_page.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HwaTab extends StatefulWidget {
  @override
  _HwaTabState createState() => _HwaTabState();
}

class _HwaTabState extends State<HwaTab> {


  List<Note> _notes = List<Note>();

  Future<List<Note>> fetchNotes() async {
    var url = 'https://raw.githubusercontent.com/boriszv/json/master/random_example.json';
    var response = await http.get(url);

    var notes = List<Note>();

    if (response.statusCode == 200) {
      var notesJson = json.decode(response.body);
      for (var noteJson in notesJson) {
        notes.add(Note.fromJson(noteJson));
      }
    }
    return notes;
  }

  @override
  void initState() {
    fetchNotes().then((value) {
      setState(() {
        _notes.addAll(value);
      });
    });
    super.initState();
  }

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position _currentPosition;
  String _currentAddress;

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       body: Container(
                decoration: BoxDecoration(
         image: DecorationImage(
           image: AssetImage("assets/images/background/bgMap.png"),
           fit: BoxFit.cover,
         ),
       ),
         child: ListView(



           children: <Widget>[
             getLocation()
           ],
         ),
       ),



         appBar: AppBar(
           backgroundColor: Colors.white,
         title: Text("단화방", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans')
         ),

           leading: InkWell(
             onTap: () => Navigator.pushNamed(context, '/profile'),
             child: CircleAvatar (
               radius: 55.0,
               backgroundImage: AssetImage("assets/images/sns/snsIconFacebook.png"),
             ),
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
     );
  }


  Container getLocation() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: 25.0,
            height: 25.0,
            child: FloatingActionButton(
                child : Image.asset('assets/images/icon/iconPin.png'),

                onPressed: () {

                  if (_currentPosition != null) {
                    print(_currentPosition);
                  }
                  _getCurrentLocation();
                }
            ),
          ),


          InkWell(
            child: Text('현재 위치', style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),


          InkWell(
            child: Text("$_currentAddress", style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Container chatListMain(){
    return Container(
      child: Column(
        children: <Widget>[
          ListView(

          )
        ],
      ),



    );
  }



  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}";
      });
    } catch (e) {
      print(e);
    }
  }
}




