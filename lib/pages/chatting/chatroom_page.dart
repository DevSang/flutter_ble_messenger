import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'dart:typed_data';
import 'package:Hwa/package/gauge/gauge_driver.dart';
import 'package:Hwa/utility/action_sheet.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hwa_beacon/hwa_beacon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/service/stomp_client.dart';
import 'package:Hwa/utility/call_api.dart';

import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_info.dart';

import 'package:Hwa/pages/chatting/notice_page.dart';
import 'package:Hwa/pages/parts/chatting/chat_side_menu.dart';
import 'package:Hwa/pages/parts/chatting/chat_message_list.dart';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-22
 * @description : 채팅 페이지
 */
class ChatroomPage extends StatefulWidget {
    final ChatInfo chatInfo;
    final bool isLiked;
    final int likeCount;
    final List<ChatJoinInfo> joinInfo;
    final List<ChatMessage> recentMessageList;
    final String from;      // HwaTab, ChatTab, Trend
    final bool disable;
    final bool isCreated;
    final bool isP2P;
    final int oppIdx;
    final String oppNick;

    ChatroomPage({Key key, this.chatInfo, this.isLiked, this.likeCount, this.joinInfo, this.recentMessageList, this.from, this.disable, this.isCreated, this.isP2P, this.oppIdx, this.oppNick}) : super(key: key);


    @override
    State createState() => new ChatScreenState(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: joinInfo, recentMessageList: recentMessageList);
}

class ChatScreenState extends State<ChatroomPage> {
    final ChatInfo chatInfo;
    final bool isLiked;
    final int likeCount;
    final List<ChatJoinInfo> joinInfo;
    final List<ChatMessage> recentMessageList;

    ChatScreenState({Key key, this.chatInfo, this.isLiked, this.likeCount, this.joinInfo, this.recentMessageList});

    // 실시간 입장 유저 리스트
    List<ChatJoinInfo> joinedUserNow;
    // 채팅방 메세지 리스트
    final List<ChatMessage> messageList = <ChatMessage>[];
    // 받은 메세지
    ChatMessage message;
    // 업로드 중인 이미지 갯수
    int uploadingImageCount;
    SharedPreferences prefs;

    // 로딩
    bool isLoading;
    // 하단 메뉴 관련
    bool isShowMenu;
    // 온라인 입장 유저 입력 불가
    bool disable;

    // 현재 채팅 Advertising condition
    BoxDecoration adCondition;
    // 현재 채팅 Advertising condition
    bool openedNf;
    // ChatTextField Focused
    bool isFocused;
    // 현재 채팅 좋아요 TODO: 추후 맵핑
    bool isLike;
    // Focus된 메세지
    int focusMsg;
    // 채팅 입력 여부
    bool isEmpty;
    // 채팅 입력 줄 수
    int inputLineCount;
    // 입력칸 높이
    int _inputHeight;
    double sameSize;

    // Stomp 관련
    StompClient s;

    // BLE 관련
    bool _activateBeacon = false;
    int _ttl = 1;
    bool advertising;

    final TextEditingController textEditingController = new TextEditingController();
    final ScrollController listScrollController = new ScrollController();
    final FocusNode focusNode = new FocusNode();

    @override
    void initState() {
        super.initState();

        checkAd();
        /// Stomp 초기화
        connectStomp();

        disable = widget.disable ?? false;
        focusNode.addListener(onFocusChange);
        isLoading = false;
        isShowMenu = false;
        advertising = true;
        isFocused = false;
        openedNf = true;
        isLike = false;
        isEmpty = true;
        inputLineCount = 1;
        _inputHeight = 36;
        uploadingImageCount = 0;
        joinedUserNow = <ChatJoinInfo>[];
        sameSize = GetSameSize().main();

        if (widget.isP2P != null && widget.isP2P == true) {
            getMyNick();
        } else {
            getMessageList();
        }
    }

    @override
    void dispose() {
	    if(Platform.isAndroid){{
		    HwaBeacon().stopAdvertising();
	    }}

        s.unsubscribe(topic: "/sub/danhwa/" + chatInfo.chatIdx.toString());
        s.disconnect();
        super.dispose();
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : 입장 시 기존 Advertising Stop
    */
    void checkAd() async {

    	if(Constant.USER_IDX == chatInfo.createUserIdx){

		    if(Platform.isAndroid){
			    bool advertising = await HwaBeacon().isAdvertising();

			    if (advertising) {
				    await HwaBeacon().stopAdvertising();
				    await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
			    }
			    else
				    await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
		    }


	    }
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : Advertising Stop/Start
    */
    void advertiseChange() async {

	    if(Platform.isAndroid){
		    if (advertising) {
			    await HwaBeacon().stopAdvertising();
			    setState(() {advertising = false;});
			    developer.log('##BLE STOP!!!');
		    } else {
			    await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
			    setState(() {advertising = true;});
                developer.log('##BLE START!!!');
		    }
	    }

    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 화면 입장 후 메세지/유저 리스트 받아오기
    */
    getMessageList() async {
        // 단화방 생성 시
        if (widget.isCreated != null && widget.isCreated) {

            joinedUserNow.add(
                ChatJoinInfo(
                    joinType: "BLE_JOIN",
                    userIdx: chatInfo.createUser.userIdx,
                    userNick: chatInfo.createUser.nick
                )
            );
            developer.log(joinedUserNow[0].userNick);
        }

        for (var recentMsg in recentMessageList) {

	        if(recentMsg != null && recentMsg.message != null) checkYoutubeAndSetVideo(recentMsg);

            messageList.add(recentMsg);
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : P2P화면 입장 후 셋팅
    */
    setP2PChat(String myNick) async {
        // 단화방 생성 시
        joinedUserNow.add(
            ChatJoinInfo(
                joinType: "ONLINE",
                userIdx: Constant.USER_IDX,
                userNick: myNick
            )
        );

        joinedUserNow.add(
            ChatJoinInfo(
                joinType: "ONLINE",
                userIdx: widget.oppIdx,
                userNick: widget.oppNick
            )
        );
    }

    /*
     * @author : hs
     * @date : 2020-01-02
     * @description : 자신의 닉네임 얻어오기 (임시)
    */
    getMyNick() async {
        /// 참여 타입 수정
        String uri = "/api/v2/user/profile?target_user_idx=" + Constant.USER_IDX.toString();
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

        Map<String, dynamic> jsonParse = json.decode(response.body);
        Map<String, dynamic> profile = jsonParse['data'];
        setP2PChat(profile['nickname']);
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : topic 구독
    */
    void connectStomp() async {
        // connect to MsgServer
        s = StompClient(urlBackend: Constant.CHAT_SERVER_WS);
        await s.connectWebSocket();
        s.connectStomp();

        // subscribe topic
        s.subscribe(topic: "/sub/danhwa/" + chatInfo.chatIdx.toString(), roomIdx: chatInfo.chatIdx.toString(), userIdx: Constant.USER_IDX.toString()).stream.listen((HashMap data) =>
            messageReceieved(data),
            onDone: () {
                developer.log("Listen Done");
            },
            onError: (error) {
                developer.log("Listen Error $error");
            }
        );
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 메세지 수신 후 처리
    */
    void messageReceieved(HashMap data) async {
        message = new ChatMessage.fromJSON(json.decode(data['contents']));
        // TODO: 추후 Image Idx 활용하여 해당 src 할당
        String imgSrc;

        developer.log("# messageReceieved : " + json.decode(data['contents']).toString());

        if (message.chatType == "ENTER") {
            joinedUserNow.add(
                ChatJoinInfo(
                    joinType: "BLE_JOIN",
                    userIdx: message.senderIdx,
                    userNick: message.nickName
                )
            );
        } else if ((message.chatType == "IMAGE" || message.chatType == "VIDEO")  && message.senderIdx == Constant.USER_IDX) {
            // 업로드 완료된 항목 삭제
            for(var i=0; i<uploadingImageCount; i++) {
                if (messageList[i].uploaded == true) {
                    imgSrc = messageList[i].message;
                    messageList.removeAt(i);
                    uploadingImageCount --;
                }
            }
        }

        ChatMessage cmb = ChatMessage(
            chatType: message.chatType,
            roomIdx: message.roomIdx,
            senderIdx: message.senderIdx,
            nickName: message.nickName,
            message: message.message,
            chatTime: message.chatTime
        );

        // youtube 체크
        checkYoutubeAndSetVideo(cmb);

        messageList.insert(uploadingImageCount, cmb);

        setState(() {});
    }

    /*
     * @author : hk
     * @date : 2020-01-08
     * @description : youtube 공유인지 체크, 맞으면 비디오 생성 및 셋팅
     */
    void checkYoutubeAndSetVideo(ChatMessage cm){
    	if(cm != null && cm.message != null){
		    String lowerCase = cm.message.toLowerCase();

		    if(lowerCase.contains("youtu.be") || lowerCase.contains("youtube")){
			    // 우튜브 Video Id 추출
			    String videoId = YoutubePlayer.convertUrlToId(cm.message);
			    developer.log("### videoId: $videoId");

			    if(videoId != null){
				    YoutubePlayerController _controller = YoutubePlayerController(
					    initialVideoId: videoId,
					    flags: YoutubePlayerFlags(
						    autoPlay: true,
					    ),
				    );

				    String thumbnailUrl = YoutubePlayer.getThumbnail(videoId: videoId);

				    YoutubePlayer video = YoutubePlayer(controller: _controller, thumbnailUrl: thumbnailUrl, showVideoProgressIndicator: true, onReady: (){
					    developer.log("###### onReady");
				    });

				    cm.youtubePlayer = video;
			    }
		    }
	    }
    }

    /*
     * @author : hs
     * @date : 2020-01-07
     * @description : Image 업로드 전 Thumbnail 말풍선에 맵핑
    */
    void thumbnailMessage(File imgFile, GaugeDriver gaugeDriver) {
        ChatMessage cmb = ChatMessage(
            chatType: "UPLOADING_IMG",
            roomIdx: chatInfo.chatIdx,
            senderIdx: Constant.USER_IDX,
            nickName: null,     /// 자신의 닉네임 맵핑
            thumbnailFile: imgFile,
            chatTime: new DateTime.now().millisecondsSinceEpoch,
            gaugeDriver: gaugeDriver,
            uploaded: false
        );

        setState(() {
            messageList.insert(0, cmb);
        });
    }

	/*
	 * @author : hk
	 * @date : 2020-01-08
	 * @description : 단화방 파일 공유
	 */
    Future<void> uploadContents(int type) async {
	    File contentsFile;
	    File thumbNailFile;

	    switch(type) {
	        case 0: contentsFile = await ImagePicker.pickImage(source: ImageSource.gallery);
	            break;
            case 1: contentsFile = await ImagePicker.pickVideo(source: ImageSource.gallery);
                break;
            case 2: contentsFile = await ImagePicker.pickImage(source: ImageSource.camera);
                break;
            case 3: contentsFile = await ImagePicker.pickVideo(source: ImageSource.camera);
                break;
        }

	    if (contentsFile != null) {
		    GaugeDriver gaugeDriver = new GaugeDriver();

		    // 파일 이외의 추가 파라미터 셋팅
		    Map<String, dynamic> param = {
			    "chat_idx" : chatInfo.chatIdx
		    };

		    String mimeStr = lookupMimeType(contentsFile.path);

		    // image, video... TODO 일반 파일 추가
		    String fileType = (mimeStr != null ? mimeStr.split("/")[0] : null);

		    developer.log("####### uploadFile. mimeStr: $mimeStr, fileType: $fileType");

            if (fileType == "video") {
                Uint8List imageThumbnailString =  await VideoThumbnail.thumbnailData(
                    video: contentsFile.path,
                    imageFormat: ImageFormat.WEBP,
                    timeMs: 0,
                    quality: 50,
                );

                thumbNailFile = File.fromRawPath(imageThumbnailString);
            } else {
                thumbNailFile = contentsFile;
            }

            thumbnailMessage(thumbNailFile, gaugeDriver);
            uploadingImageCount ++;

		    // 파일 업로드 API 호출
		    Response response = await CallApi.fileUploadCall(
				    url: "/api/v2/chat/share/file"
				    , filePath: contentsFile.path
				    , paramMap: param
				    , contentsType: mimeStr
				    , onSendProgress: (int sent, int total){

			    developer.log("$sent : $total");

			    for(var i=0; i<uploadingImageCount; i++) {
				    if (messageList[i].thumbnailFile.path == thumbNailFile.path) {
					    messageList[i].gaugeDriver.drive(sent/total);

					    if(sent == total) {
						    messageList[i].uploaded = true;
					    }
				    }

				    break;
			    }
		    }, onError: (DioError e){
			    // TODO 서버 에러일 경우 처리
			    developer.log("########### DioError");
			    developer.log(e.toString());
			    developer.log(e.message);
			    developer.log(e.type.toString());
		    });

		    if(response.statusCode == 200){
			    await precacheImage(
					    CachedNetworkImageProvider(
							    "https://api.hwaya.net/api/v2/chat/share/file?file_idx=" + response.data["data"].toString() + "&type=SMALL", headers: Constant.HEADER
					    ), context);

			    // 썸네일 URI 전송
			    onSendMessage("https://api.hwaya.net/api/v2/chat/share/file?file_idx=" + response.data["data"].toString() + "&type=SMALL", fileType.toUpperCase());
		    }
	    }
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : Focus 감지에 따른 화면
    */
    void onFocusChange() {
        if (focusNode.hasFocus) {
            // Hide sticker when keyboard appear
            setState(() {
                isShowMenu = false;
            });
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-24
     * @description : 하단 Menu 처리 Show <-> Hide
    */
    void getMenu() {
        // Hide keyboard when menu appear
        focusNode.unfocus();
        setState(() {
            isShowMenu = !isShowMenu;
        });
    }

    /*
     * @author : hs
     * @date : 2020-01-05
     * @description : 메세지 전송
    */
    void onSendMessage(dynamic content, String type) {
        String message;
        String sendType;

        if (content.trim() != '') {
            textEditingController.clear();
//            switch(type){
//	            case 0: sendType = "TALK"; break;
//	            case 1: sendType = "IMAGE"; break;
//	            case 2: sendType = "VIDEO"; break;
//	            case 3: sendType = "SERVICE"; break;
//	            case 4: sendType = "FILE"; break;
//            }
        }

        final int now = new DateTime.now().microsecondsSinceEpoch ~/ 1000;
        message = '{"type": "'+ type +'","roomIdx":' + chatInfo.chatIdx.toString() + ',"senderIdx":' + Constant.USER_IDX.toString() + ',"message": "' + content.toString() + '","userCountObj":null,"createTs":' + now.toString() + '}';

        /// MESSAGE SEND
        s.send(
            topic: "/pub/danhwa",
            message: message
        );
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 마지막 보낸 메세지
    */
    bool isLastSendMessage(int index) {
        if ((index > 0 && messageList != null && messageList[index - 1].senderIdx != Constant.USER_IDX) || index == 0) {
            return true;
        } else {
            return false;
        }
    }

    /*
     * @author : hs
     * @date : 2020-01-05
     * @description : 입력창 클릭시 동작
    */
    void _onTapTextField() {
        isFocused
            ? null
            : setState(() {
                isFocused = true;
                isShowMenu = false;
            });
    }

    /*
     * @author : hs
     * @date : 2020-01-05
     * @description : Page 뒤로가기 동작
    */
    void popPage() async {

        setState(() {
            isLoading = true;

            if (isShowMenu) {
                isShowMenu = false;
            }
        });

        if(Platform.isAndroid){
	        advertising = false;
	        await HwaBeacon().stopAdvertising();
        }

        setState(() {
            isLoading = false;
        });

	    Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                title: Text(
                    chatInfo.title ?? " ",
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16)
                    ),
                ),
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconPrev.png'),
                    onPressed: (){
                        popPage();
                    }
                ),
                actions:[
                    chatInfo.createUser.userIdx == Constant.USER_IDX
                        ? GestureDetector(
                            child: Container(
                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(5)),
                                width: ScreenUtil().setWidth(27),
                                height: ScreenUtil().setHeight(27),
                                decoration: advertising ? startAd(context) : stopAd(context)
                            ),
                            onTap:(){
                                advertiseChange();
                            }
                        )
                        : Container()
                    ,
                    Builder(
                        builder: (context) => IconButton(
                            icon: new Image.asset('assets/images/icon/navIconMenu.png'),
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                        ),
                    ),
                ],
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                brightness: Brightness.light,
            ),
            endDrawer: SafeArea(
                child: new ChatSideMenu(
                    chatInfo: chatInfo,
                    isCreated: widget.isCreated,
                    isLiked: isLiked,
                    likeCount: likeCount,
                    chatJoinInfoList: joinInfo,
                    joinedUserNow: joinedUserNow,
                    sc: s,
                    from: widget.from
                )
            ),
            body: GestureDetector(
                child: Stack(
                    children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(250, 250, 251, 1),
                                border: Border(
                                    top: BorderSide(
                                        width: ScreenUtil().setWidth(0.5),
                                        color: Color.fromRGBO(178, 178, 178, 0.8)
                                    )
                                )
                            ),
                            child: Column(
                                children: <Widget>[
                                    // List of messages
                                    ChatMessageList(messageList: messageList),

                                    // Input content
                                    disable ? Container() : buildInput(),

                                    /// 하단 메뉴 서비스 추가 시 코드 교체
                                    // Menu
//                                            (isShowMenu && !isFocused ? buildMenu() : Container()),
                                ],
                            ),
                        ),

                        // Notification
                        openedNf ? buildNoticeOpen() : buildNotice(),

                        // Loading
                        isLoading ? Loading() : Container()
                    ],
                ),
                onTap: () {
                    FocusScope.of(context).requestFocus(focusNode);
                },
            )
        );
    }

    BoxDecoration startAd(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(77, 96, 191, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconUnlock.png")
            ),
            shape: BoxShape.circle
        );

    }

    BoxDecoration stopAd(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(153, 153, 153, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLock.png")
            ),
            shape: BoxShape.circle
        );

    }

    Widget buildNotice() {
        return Positioned(
            top: ScreenUtil().setHeight(10),
            right: ScreenUtil().setWidth(10),
            child: GestureDetector(
                child: Container(
                    width: ScreenUtil().setWidth(33),
                    height: ScreenUtil().setHeight(33),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image:AssetImage("assets/images/icon/iconBell.png")
                        ),
                        shape: BoxShape.circle
                    )
                ),
                onTap:(){
                    setState(() {
                      openedNf = true;
                    });
                }
            )
        );
    }

    Widget buildNoticeOpen() {
        return Positioned(
            top: ScreenUtil().setHeight(8),
            left: ScreenUtil().setWidth(8),
            child: Container(
                width: ScreenUtil().setWidth(359),
                height: ScreenUtil().setHeight(37),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(4)),
                    ),
                    boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: ScreenUtil().setWidth(2), // has the effect of softening the shadow
                            spreadRadius: ScreenUtil().setWidth(0),
                            offset: new Offset(0, ScreenUtil().setWidth(2))
                        )
                    ]
                ),
                child: Row(
                    children: <Widget>[
                        GestureDetector(
                            child: Row(
                                children: <Widget> [
                                    Container(
                                        width: ScreenUtil().setWidth(20),
                                        height: ScreenUtil().setHeight(20),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setHeight(11)
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                                image:AssetImage("assets/images/icon/iconBell.png")
                                            )
                                        )
                                    ),
                                    Container(
                                        width: ScreenUtil().setWidth(282),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setHeight(8.5),
                                            right: ScreenUtil().setHeight(8.5)
                                        ),
                                        child: Text(
                                            '타인을 향한 비방시 강퇴 조치를 취합니다.',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: ScreenUtil.getInstance().setWidth(-0.65),
                                                fontSize: ScreenUtil().setSp(13),
                                                color: Color.fromRGBO(39, 39, 39, 1)
                                            ),
                                        )
                                    ),
                                ]
                            ),
                            onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                        return NoticePage(chatIdx: 0);
                                    })
                                );
                            },
                        ),
                        Container(
                            width: ScreenUtil().setWidth(20),
                            child: FlatButton(
                                onPressed:(){
                                    setState(() {
                                        openedNf = false;
                                    });
                                }
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    image:AssetImage("assets/images/icon/iconFold.png")

                            ),
                            shape: BoxShape.circle
                            ),
                        )
                    ],
                )
            )
        );
    }

    BoxDecoration setIcon(String iconPath) {
        return BoxDecoration(
            color: Color.fromRGBO(245, 245, 245, 1),
            image: DecorationImage(
                image:AssetImage(iconPath)
            ),
            shape: BoxShape.circle
        );
    }

    Widget buildInput() {
        return Container(
            width: double.infinity,
            decoration: new BoxDecoration(
                color: Colors.white
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                    isFocused ? chatIconClose() : chatIconOpen(),
                    // Edit text
                    Container(
                        width: isFocused ? ScreenUtil().setWidth(343) :ScreenUtil().setWidth(230),
                        margin: EdgeInsets.symmetric(
                            vertical: sameSize*6
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(245, 245, 245, 1),
                            border: Border.all(
                                color: Color.fromRGBO(214, 214, 214, 1),
                                width: sameSize*1
                            ),
                            borderRadius: BorderRadius.all(
                                Radius.circular(sameSize*18)
                            )
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                                Expanded (
                                    child: Container(
                                        width: isFocused ? ScreenUtil().setWidth(301) : ScreenUtil().setWidth(188),
                                        height: sameSize*(_inputHeight - 2),
                                        margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),

                                        child: new ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight: sameSize*34,
                                                maxHeight: sameSize*106
                                            ),

                                            child: new SingleChildScrollView(
                                                scrollDirection: Axis.vertical,

                                                // here's the actual text box
                                                child: new TextField(
                                                    keyboardType: TextInputType.multiline,
                                                    controller: textEditingController,
                                                    minLines: 1,
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                        fontSize: ScreenUtil().setSp(15),
                                                        letterSpacing: ScreenUtil().setWidth(-1.15),
                                                    ),
                                                    decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.only(
                                                            left: sameSize*13,
                                                            right: sameSize*9,
                                                            bottom: sameSize*8
                                                        )
                                                    ),
                                                    autofocus: false,
                                                    onTap: _onTapTextField,
                                                    onChanged: (String chat){
                                                        int count = '\n'.allMatches(chat).length + 1;
                                                        if (chat.length == 0 && inputLineCount == count) {
                                                            setState(() {
                                                                isEmpty = true;
                                                            });
                                                        } else if (inputLineCount != count && count <= 5) {  // use a maximum height of 6 rows
                                                            // height values can be adapted based on the font size
                                                            var inputHeight = 18 + (count * 18);

                                                            setState(() {
                                                                inputLineCount = count;
                                                                _inputHeight = inputHeight;

                                                                if (chat.length == 0) isEmpty = true;
                                                                else isEmpty = false;
                                                            });
                                                        } else {
                                                            setState(() {
                                                                isEmpty = false;
                                                            });
                                                        }
                                                    },
                                                ),
                                                // ends the actual text box

                                            ),

                                        )
                                    )
                                ),
                                // Button send message
                                Container(
                                    margin: EdgeInsets.only(
                                        right: ScreenUtil().setWidth(3),
                                        bottom: ScreenUtil().setWidth(3),
                                        top: ScreenUtil().setWidth(3)
                                    ),
                                    child:
                                    GestureDetector(
                                        child: Container(
                                            width: sameSize*28,
                                            height: sameSize*28,
                                            decoration: BoxDecoration(
                                                color: isEmpty
                                                            ? Color.fromRGBO(204, 204, 204, 1)
                                                            : Color.fromRGBO(77, 96, 191, 1)
                                                ,
                                                image: DecorationImage(
                                                    image:AssetImage('assets/images/icon/iconSendMessage.png')
                                                ),
                                                shape: BoxShape.circle
                                            )
                                        ),
                                        onTap:(){
                                            onSendMessage(textEditingController.text, "TALK");
                                        }
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(sameSize*18)
                                        )
                                    ),
                                ),
                            ],
                        )
                    ),
                ],
            ),
        );
    }

    Container chatIconClose() {
        return Container(
            child:
            GestureDetector(
                child: Container(
                    padding: EdgeInsets.only(
                        left: sameSize*4,
                        right: sameSize*4,
                        bottom: sameSize*16,
                    ),
                    width: sameSize*26,
                    height: sameSize*48,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:AssetImage('assets/images/icon/iconAttachFold.png')
                        ),
                    )
                ),
                onTap:(){
                    setState(() {
                        isFocused = false;
                    });
                }
            ),
        );
    }

    Container chatIconOpen() {
        return Container(
            width: ScreenUtil().setWidth(139),
            child: Row(
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(8),
                            right: ScreenUtil().setWidth(12),
                            bottom: ScreenUtil().setWidth(8),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(0)),
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setWidth(32),
                                decoration: setIcon(
                                    /// 하단 메뉴 서비스 추가 시 코드 교체
//                                    isShowMenu
//                                        ? 'assets/images/icon/iconAttachClose.png'
//                                        : 'assets/images/icon/iconAttachMore.png'
                                    'assets/images/icon/iconAttachCard.png'
                                )
                            ),
                            onTap:(){
                                /// 하단 메뉴 서비스 추가 시 코드 교체
//                                getMenu();
                                FocusScope.of(context).unfocus();
                                dialogBC(context);
                            }
                        ),
                        color: Colors.white,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(12),
                            bottom: ScreenUtil().setWidth(8),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setWidth(32),
                                decoration: setIcon('assets/images/icon/iconAttachCamera.png')
                            ),
                            onTap:(){
                                ActionSheetState().showActionSheet(
                                    context: context, child: _buildActionSheet(true)
                                );
                            }
                        ),
                        color: Colors.white,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(11),
                            bottom: ScreenUtil().setWidth(8),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setWidth(32),
                                decoration: setIcon('assets/images/icon/iconAttachPhoto.png')
                            ),
                            onTap:(){
                                ActionSheetState().showActionSheet(
                                    context: context, child: _buildActionSheet(false)
                                );
                            }
                        ),
                        color: Colors.white,
                    ),
                ],
            ),
        );
    }

    Widget _buildActionSheet(bool fromCamera) {
        return CupertinoActionSheet(
            message: Text(
                "단화방에 공유할 미디어를 선택해주세요.",
                style: TextStyle(
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenUtil().setSp(14),
                ),
            ),
            actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text("사진"),
                    onPressed: () {
                        fromCamera ?  uploadContents(2) : uploadContents(0);
                        Navigator.pop(context);
                    },
                ),
                CupertinoActionSheetAction(
                    child: Text("동영상"),
                    onPressed: () {
                        fromCamera ?  uploadContents(3) : uploadContents(1);
                        Navigator.pop(context);
                    },
                )
            ],
            cancelButton: CupertinoActionSheetAction(
                child: Text("취소"),
                onPressed: () {
                    Navigator.pop(context);
                },
            ),
        );
    }

    Future dialogBC(BuildContext context) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10)))
                    ),
                    contentPadding: EdgeInsets.all(0),
                    content: Container(
                        width: ScreenUtil().setWidth(281),
                        height: ScreenUtil().setHeight(291),
                        padding: EdgeInsets.all(0),
                        child: Column(
                            children: <Widget>[
                                Container(
                                    width: ScreenUtil().setWidth(281),
                                    height: ScreenUtil().setHeight(42),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: ScreenUtil().setWidth(1),
                                                color: Color.fromRGBO(39, 39, 39, 0.15)
                                            )
                                        )
                                    ),
                                    child: Center(
                                        child: Text(
                                            '명함 공유',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w500,
                                                fontSize: ScreenUtil(allowFontScaling: true).setSp(16),
                                                color: Color.fromRGBO(39, 39, 39, 1),
                                                letterSpacing: ScreenUtil().setWidth(-0.8),
                                            ),
                                        ),
                                    ),
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(200),
                                    height: ScreenUtil().setHeight(111),
                                    margin: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(14),
                                        bottom: ScreenUtil().setHeight(14),
                                    ),
                                    child: Image.asset(
                                        'assets/images/businesscard.png',
                                        fit:BoxFit.fitWidth
                                    ),
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(281),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                                width: ScreenUtil().setWidth(1),
                                                color: Color.fromRGBO(39, 39, 39, 0.15)
                                            )
                                        )
                                    ),
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(21),
                                        ),
                                        child: Text(
                                            '현재 단화방에 명함을 공유하시겠습니까?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                height: 1,
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: ScreenUtil.getInstance().setHeight(-0.33),
                                                fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                                                color: Color.fromRGBO(107, 107, 107, 1)
                                            )
                                        )
                                    )
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(21),
                                        bottom: ScreenUtil().setHeight(17),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            cardShareButton(1, (){
                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                            }),
                                            cardShareButton(2, (){
                                                /// FileUpload 명함
                                                onSendMessage('assets/images/businesscard.png', "SERVICE");
                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                            }),
                                        ],
                                    )
                                )
                            ],
                        ),
                    )
                );
            }
        );
    }

    Widget cardShareButton(int index, Function fn) {
        String title = index == 1 ? '취소' : '공유하기';
        Color tabColor = index == 1 ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(77, 96, 191, 1);
        Color borderColor = index == 1 ? Color.fromRGBO(158, 158, 158, 1) : Color.fromRGBO(77, 96, 191, 1);
        Color textColor = index == 1 ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(255, 255, 255, 1);

        return InkWell(
            child: Container(
                width: ScreenUtil().setWidth(125),
                height: ScreenUtil().setHeight(36),
                margin: EdgeInsets.only(
                    left: index == 2 ? ScreenUtil().setWidth(5) : 0,
                ),
                decoration: BoxDecoration(
                    color: tabColor,
                    border: Border.all(
                        width: ScreenUtil().setWidth(1),
                        color: borderColor,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(20))
                    )
                ),
                child: Center (
                    child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            letterSpacing: ScreenUtil.getInstance().setHeight(-0.33),
                            fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                            color: textColor
                        ),
                    ),
                ),
            ),
            onTap: () {
                fn();
            },
        );
    }

    ///
    /// 하단 메뉴 서비스 추가 시 코드 활용-------------------
    ///
    Widget buildMenu() {

        return Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(216),
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(21.5),
                bottom: ScreenUtil().setHeight(21.5),
                left: ScreenUtil().setHeight(8),
                right: ScreenUtil().setHeight(8),
            ),
            child: Column(
                children: <Widget>[
                    Container(
                        child: Row(
                            children: <Widget>[
                                buildMenuItem("assets/images/icon/iconViewCard.png", "명함", dialogBC),
                                buildMenuItem("assets/images/icon/iconWallet.png", "거래", null),
                                buildMenuItem("assets/images/icon/iconCar.png", "합승/카풀", null)
                            ],
                        )
                    )
                ],
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        width: ScreenUtil().setWidth(2),
                        color: Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
        );
    }

    Widget buildMenuItem(String imgSrc, String name, dynamic widget) {
        return
            Container(
                width: ScreenUtil().setWidth(88),
                height: ScreenUtil().setHeight(86.5),
                child: Column(
                    children: <Widget>[
                        Container(
                            width: ScreenUtil().setWidth(50),
                            height: ScreenUtil().setHeight(50),
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(9.5)
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(210, 217, 250, 1),
                                image: DecorationImage(
                                    image:AssetImage(imgSrc)
                                ),
                                shape: BoxShape.circle
                            ),
                            child:
                            FlatButton(
                                onPressed: () => {
                                    name == "명함"
                                        ? widget(context)
                                        : Container()
                                },
                            )
                        ),
                        Container(
                            child: Text(
                                name,
                                style: TextStyle(
                                    height: 1,
                                    fontSize: ScreenUtil().setSp(13)
                                ),
                            )
                        )
                    ],
                ),
            );
    }

}