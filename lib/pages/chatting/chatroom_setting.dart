import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/custom_dialog.dart';
import 'package:Hwa/utility/custom_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/chat_info.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Hwa/constant.dart';
import 'dart:developer' as developer;

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-26
 * @description : 채팅 설정 페이지
 */
class ChatroomSettingPage extends StatefulWidget {
    final ChatInfo chatInfo;

    ChatroomSettingPage({Key key, @required this.chatInfo}) : super(key: key);

    @override
    State createState() => new ChatroomSettingPageState(chatInfo: chatInfo);
}

class ChatroomSettingPageState extends State<ChatroomSettingPage> {
    ChatroomSettingPageState({Key key, @required this.chatInfo});

    final ChatInfo chatInfo;
    ChatInfo chatSettingUpdated = new ChatInfo();

    int _selectedModeIdx;
    List<String> chatMode = ["누구나 단화", "방장만 공지", "방장과 대화"];
    List<String> inviteRange = ["좁게", "보통", "넓게"];

    bool isLoading;
    bool isProfileLoading;

    String profileImgUri;

    CachedNetworkImage cachedNetworkImage;

    @override
    void initState() {

	    profileImgUri = Constant.API_SERVER_HTTP + "/api/v2/chat/profile/image?chat_idx=" + chatInfo.chatIdx.toString() + "&type=SMALL";

	    cachedNetworkImage = CachedNetworkImage(
            imageUrl: profileImgUri,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Image.asset(chatInfo.chatImg,fit: BoxFit.cover),
            httpHeaders: Constant.HEADER
	    );

        chatSettingUpdated.chatImg = chatInfo.chatImg;
        chatSettingUpdated.title = chatInfo.title;
        chatSettingUpdated.intro = chatInfo.intro;
        chatSettingUpdated.isPublic = chatInfo.isPublic;
        chatSettingUpdated.inviteRange = chatInfo.inviteRange;
        chatSettingUpdated.mode = chatInfo.mode;

        _selectedModeIdx = 0;
        isLoading = false;
	    super.initState();
    }

    /*
     * @author : hs
     * @date : 2020-01-02
     * @description : get picker value
    */
    void getPickerValue(String setType) async {
        // setType : mode / inviteRange

        int selectedValue = await showModalBottomSheet<int>(
            context: context,
            builder: (BuildContext context) {
                return setType == "mode"
                    ? _buildBottomPicker(chatSettingUpdated.mode, setType)
                    : _buildBottomPicker(chatSettingUpdated.inviteRange, setType);
            },
        );

        if (selectedValue != null) {
            setState(() {
                if (setType == "mode") {
                    chatSettingUpdated.mode = chatMode[selectedValue];
                    _selectedModeIdx = selectedValue;
                } else {
                    chatSettingUpdated.inviteRange = selectedValue;
                }
            });
        }
    }

    /*
     * @author : hs
     * @date : 2020-01-02
     * @description : 설정 저장 및 페이지 이동
    */
    void popNav() async {
        setState(() {
            isLoading = true;
        });

        await saveSettingInfo();

        setState(() {
            isLoading = false;
        });

        Navigator.of(context).pop();
    }

    /*
     * @author : hs
     * @date : 2020-01-01
     * @description : 단화 설정 저장
    */
    Future<void> saveSettingInfo() async {
        try {
            String uri = "/danhwa/room/update?roomIdx=" + chatInfo.chatIdx.toString();
            uri += "&title=" + chatSettingUpdated.title;
            uri += "&intro=" + chatSettingUpdated.intro;
            uri += "&isPublic=" + chatSettingUpdated.isPublic.toString();
            uri += "&inviteRange=" + chatSettingUpdated.inviteRange.toString();
            uri += "&chatMode=" + chatSettingUpdated.mode;

            var encoded = Uri.encodeFull(uri);

            final response = await CallApi.messageApiCall(
                method: HTTP_METHOD.post,
                url: encoded
            );

            return;

        } catch (e) {
            developer.log("#### Error :: " + e.toString());
            return;
        }
    }

	/*
	 * @project : HWA - Mobile
	 * @author : hk
	 * @date : 2020-01-02
	 * @description : 단화방 프로필사진 업로드
	 */
    void updateRoomImg(int flag) async {

	    File imageFile;

	    if(flag == 0){
		    // 사진첩 열기
		    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
	    } else {
		    // 카메라 열기
		    imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
	    }

	    if(imageFile != null){
		    setState(() {
                isLoading = true;
		    });

		    Map<String, dynamic> paramMap = {
			    "chat_idx" : chatInfo.chatIdx.toString()
		    };

		    // 파일 업로드 API 호출
		    Response response = await CallApi.fileUploadCall(url: "/api/v2/chat/profile/image", filePath: imageFile.path, paramMap: paramMap ,onSendProgress: (int sent, int total){
                developer.log("$sent : $total");
		    });

		    if(response.statusCode == 200){
			    await DefaultCacheManager().removeFile(profileImgUri);

			    setState(() {
				    cachedNetworkImage = CachedNetworkImage(
                        imageUrl: profileImgUri,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        httpHeaders: Constant.HEADER
				    );

                    isLoading = false;
			    });
		    } else {
			    developer.log("## 이미지파일 업로드에 실패하였습니다.");
		    }
	    }
    }

    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);

        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                brightness: Brightness.light,
                title: Text(
                    "단화방 설정",
                    style: TextStyle(
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16),
                        fontFamily: "NotoSans"
                    ),
                ),
                elevation: 0.0,
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconClose.png'),
                    onPressed: (){
                        Navigator.of(context).pop();
                    }
                ),
                actions:[
                    Builder(
                        builder: (context) =>
                            Row(
                                children: <Widget>[
                                    Container (
                                        margin: EdgeInsets.only(
                                            right: ScreenUtil().setWidth(16),
                                        ),
                                        child: GestureDetector(
                                            child: Text(
                                                '저장',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(77, 96, 191, 1),
                                                    letterSpacing: ScreenUtil().setWidth(-0.75),
                                                    fontSize: ScreenUtil.getInstance().setSp(15),
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w500
                                                ),
                                            ),
                                            onTap: () {
                                                popNav();
                                            },
                                        )
                                    ),
                                ],
                            ),
                    ),
                ],
                centerTitle: true,
                backgroundColor: Colors.white,
            ),
            body: buildChatSetting(),
        );
    }

    Widget buildChatSetting() {
        return
            Stack(
                children: <Widget>[
                    Column(
                        children: <Widget>[
                            Flexible(
                                child: ListView(
                                    children: <Widget>[
                                        buildChatImage(),

                                        buildChatSettingList()
                                    ]
                                )
                            )
                        ],
                    ),
                    isLoading ? Loading() : Container()
                ]
        );
    }

    Widget buildChatImage() {
        return Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(177),
            color: Color.fromRGBO(214, 214, 214, 1),
            child: Stack(
                children: <Widget>[
                    InkWell(
                        child: Center(
                            child: Container(
                                width: ScreenUtil().setHeight(90),
                                height: ScreenUtil().setHeight(90),
                                margin: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(42),
                                    bottom: ScreenUtil().setHeight(46),
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: ScreenUtil().setWidth(1),
                                        color: Color.fromRGBO(0, 0, 0, 0.05)
                                    ),
                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(22.5)),
                                ),
                                child: ClipRRect(
                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(22.5)),
                                    child: cachedNetworkImage
//	                                    Image.asset(
//	                                        chatInfo.chatImg,
//	                                        fit: BoxFit.cover,
//	                                    )


                                ),
                            ),
                        ),
                        onTap: () {
                            updateRoomImg(0);
                        },
                    ),
                    Positioned(
                        bottom: ScreenUtil().setHeight(41),
                        left: ScreenUtil().setWidth(206),
                        child: InkWell(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setHeight(32),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(77, 96, 191, 1),
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/icon/iconAttachCamera.png")
                                    ),
                                    shape: BoxShape.circle
                                )
                            ),
                            onTap:(){
	                            updateRoomImg(1);
                            }
                        )
                    )
                ],
            ),
        );
    }

    Widget buildChatSettingList() {
        return Container(
            child: Column(
                children: <Widget>[

                    buildTextItem(
                        '단화방 이름',
                        chatSettingUpdated.title,
                        "Dialog"
                    ),

                    buildTextItem(
                        '단화방 소개',
                        chatSettingUpdated.intro  ?? "단화방을 소개해 보세요",
                        "Dialog"
                    ),

                    buildSwitchItem(
                        '온라인 공개',
                        chatSettingUpdated.isPublic,
                        (val) => {
                            developer.log(val)
                        }
                    ),

                    buildTextItem(
                        '초대 범위',
                        inviteRange[chatSettingUpdated.inviteRange],
                        "Selector"
                    ),

                    buildTextItem(
                        '단화방 모드',
                        chatSettingUpdated.mode,
                        "Selector"
                    ),
                ],
            ),
        );
    }

    Widget buildTextItem(String title, String value, dynamic fn) {
        return Container(
            height: ScreenUtil().setHeight(49),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(8)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    InkWell(
                        child: Row(
                            children: <Widget>[
                                Text(
                                    value,
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        fontSize: ScreenUtil.getInstance().setSp(15),
                                        letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                                    )
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(20),
                                    height: ScreenUtil().setHeight(20),
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(6)
                                    ),
                                    child: Image.asset(
                                        'assets/images/icon/iconMore.png'
                                    )
                                )
                            ],
                        ),
                        onTap: () {
                            fn == "Dialog"
                                ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) => CustomDialog(
                                        title: title,
                                        type: 1,
                                        leftButtonText: "취소",
                                        rightButtonText: "저장하기",
                                        value: value
                                    ),
                                ).then((onValue) {
                                    if (onValue != null) {
                                        setState(() {
                                            if (title == "단화방 이름")
                                                chatSettingUpdated.title = onValue;
                                            else if (title == "단화방 소개")
                                                chatSettingUpdated.intro = onValue;
                                        });
                                    }
                                })
                                : getPickerValue(title == "단화방 모드" ? "mode" : "inviteRange");
                        },
                    )
                ],
            )
        );
    }

    Widget buildSwitchItem(String title, bool value, Function fn) {
        return Container(
            height: ScreenUtil().setHeight(49),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(8)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    CustomSwitch(
                        onChanged: (val){
                            fn(val);
                        } ,
                        value: value ?? true,
                        inactiveColor: Color.fromRGBO(235, 235, 235, 1),
                        activeColor: Color.fromRGBO(77, 96, 191, 1),
                    )
                ],
            )
        );
    }

    Widget buildRangeItem(String title, int _value) {
        return Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(49),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(8)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Container(
                        child: Slider(
                            min: 1.0,
                            max: 3.0,
                            value: _value.toDouble(),
                            divisions: 3,
                            onChanged: (value) {
                                developer.log(value.round().toString());
                                setState(() {
                                    _value = value.round();
                                });
                            },
                        ),
                    )
                ],
            )
        );
    }

    Widget buildSelectItem(String title, int value) {
        return Container();
    }

    Widget _buildBottomPicker(dynamic value, String setType) {
        int _selectedItemIdx;
        List<String> setTypeList;

        if (setType == "mode") {
            _selectedItemIdx = _selectedModeIdx;
            setTypeList = chatMode;
        } else {
            _selectedItemIdx = value;
            setTypeList = inviteRange;
        }

        FixedExtentScrollController scrollController = new FixedExtentScrollController(initialItem: _selectedItemIdx);

        return new Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(210),
            child: Column(
                children: <Widget>[
                    Container(
                        height: ScreenUtil().setHeight(40),
                        width: ScreenUtil().setWidth(375),
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(16),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                                InkWell(
                                    child: Text(
                                        '확인',
                                        style: TextStyle(
                                            color: Color.fromRGBO(107, 107, 107, 1),
                                            letterSpacing: ScreenUtil().setWidth(-0.75),
                                            fontSize: ScreenUtil.getInstance().setSp(15),
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w500
                                        ),
                                    ),
                                    onTap: () {
                                        Navigator.of(context).pop(_selectedItemIdx);
                                    },
                                )
                            ],
                        )
                    ),
                    Container(
                        height: ScreenUtil().setHeight(170),
                        width: ScreenUtil().setWidth(375),
                        child: GestureDetector(
                            // Blocks taps from propagating to the modal sheet and popping.
                            child: new SafeArea(
                                child: new CupertinoPicker(
                                    scrollController: scrollController,
                                    itemExtent: 50,
                                    backgroundColor: CupertinoColors.white,
                                    onSelectedItemChanged: (int index) {
                                        setState(() {
                                            _selectedItemIdx = index;
                                        });
                                    },
                                    children: List<Widget>.generate(
                                        setTypeList.length,
                                        (int index) {
                                            return Center(
                                                child: new Text(
                                                    setTypeList[index]
                                                ),
                                            );
                                        }
                                    ),
                                ),
                            ),
                        )
                    )
                ],
            ),
        );
    }

}