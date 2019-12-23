import 'package:flutter/material.dart';
import 'package:Hwa/app.dart';
import 'package:flutter/services.dart';


final TextEditingController _regNameController = new TextEditingController();

class SignUpNamePage extends StatefulWidget{


  @override
  _SignUpNamePageState createState() => _SignUpNamePageState();
}
class _SignUpNamePageState extends State<SignUpNamePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("회원가입",style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans'),
          ),
        ),
      body: Container(
        child: ListView(
          children: <Widget>[
            _regNickTextField(),
            _regAuthTextField(),
            _regStartBtn(context)
          ]
        ),
      ),

    );
  }
}

Widget _regNickTextField(){
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("닉네임 입력",style: TextStyle(color: Colors.black87, fontSize: 13,fontFamily: 'NotoSans'))
        ],
      )
  );
}



Widget _regAuthTextField(){
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
    child: TextFormField(
        onChanged: (regNickname) {
          print(regNickname);
        },
        onFieldSubmitted: (regNickname) {
          print('닉네임 입력 :$regNickname');
        },
        keyboardType: TextInputType.text,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        controller: _regNameController,
        cursorColor: Colors.white,
        obscureText: true,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          hintText: "닉네임을 입력하세요",
          hintStyle: TextStyle(color: Colors.black38),
          border:  OutlineInputBorder(
            borderRadius:  BorderRadius.circular(10.0),
            borderSide:  BorderSide(
            ),
          ),
          fillColor: Colors.grey[200],
          filled: true,
        )
    ),
  );
}



Widget _regStartBtn(BuildContext context){
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50.0,
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    child: RaisedButton(
      onPressed:(){
        Navigator.pushNamed(context, '/main');
      },
      color: Colors.black38,
      elevation: 0.0,
      child: Text("시작하기", style: TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),

    ),
  );
}


