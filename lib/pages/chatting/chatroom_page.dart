import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hwa_beacon/hwa_beacon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';

import 'package:Hwa/package/gauge/gauge_driver.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_notice_item.dart';
import 'package:Hwa/utility/action_sheet.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/service/stomp_client.dart';
import 'package:Hwa/pages/chatting/notice_page.dart';
import 'package:Hwa/pages/parts/chatting/chat_side_menu.dart';
import 'package:Hwa/pages/parts/chatting/chat_message_list.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/data/state/chat_notice_item_provider.dart';

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

class ChatScreenState extends State<ChatroomPage> with WidgetsBindingObserver {

	AppLifecycleState _appLifecycleState;

    final ChatInfo chatInfo;
    final bool isLiked;
    final int likeCount;
    final List<ChatJoinInfo> joinInfo;
    final List<ChatMessage> recentMessageList;

    ChatScreenState({Key key, this.chatInfo, this.isLiked, this.likeCount, this.joinInfo, this.recentMessageList});

    List<ChatJoinInfo> joinedUserNow;                       // 실시간 입장 유저 리스트
    final List<ChatMessage> messageList = <ChatMessage>[];  // 채팅방 메세지 리스트

    int uploadingImageCount;    // 업로드 중인 이미지 갯수
    bool isLoading;             // 로딩
    bool isShowMenu;            // 하단 메뉴 관련
    bool disable;               // 온라인 입장 유저 입력 불가
    BoxDecoration adCondition;  // 현재 채팅 Advertising condition
    bool openedNf;              // 공지사항 관련
    bool isFocused;             // ChatTextField Focused
    bool isLike;                // 현재 채팅 좋아요 TODO: 추후 맵핑
    int focusMsg;               // Focus 된 메세지
    bool isEmpty;               // 채팅 입력 여부
    int inputLineCount;         // 채팅 입력 줄 수
    int _inputHeight;           // 입력칸 높이
    double sameSize;
    double dragGestureInit;
    double dragGestureDistance;

    // 프로필 이미지를 가지고 있는 사용자 셋
    Set<int> profileImgExistUserSet = Set<int>();

    // Stomp 관련
    StompClient s;
    bool isWsConnected = false;     // WS 연결 됐는지 여부
    Timer _wsTimer;                 // WS 접속실패 재 연결 타이머
    int wsReconnectDelay = 2000;    // WS 재 연결시도 시간

    // BLE 관련
    bool _activateBeacon = false;
    int _ttl = 1;
    bool advertising;

    final TextEditingController textEditingController = new TextEditingController();
    final ScrollController listScrollController = new ScrollController();
    final FocusNode focusNode = new FocusNode();
    ChatRoomNoticeInfoProvider chatRoomNoticeInfoProvider;

	@override
	void didChangeAppLifecycleState(AppLifecycleState state) {
		_appLifecycleState = state;

		if(state == AppLifecycleState.paused && ModalRoute.of(context).isCurrent){
			// App 이 background 로 변환 될때 BLE 서비스 등 중지
			developer.log("### App state. paused - Chat Room");


		} else if(state == AppLifecycleState.resumed && ModalRoute.of(context).isCurrent){
			// App 이 foreground 로 변환 될때 BLE 서비스 등 재 시작
			developer.log("### App state. resumed - Chat Room");

		}
	}

    @override
    void initState() {
	    super.initState();

	    // App Lifecycle observer 등록
	    WidgetsBinding.instance.addObserver(this);

        chatRoomNoticeInfoProvider = Provider.of<ChatRoomNoticeInfoProvider>(context, listen: false);
        _initState();

        // 입장한 사용자 중 프로필 이미지가 있는 사용자 정보 추출
        if(joinInfo != null) {
	        joinInfo.forEach((ChatJoinInfo user) {
	        	if(user.profilePictureIdx != null) profileImgExistUserSet.add(user.userIdx);
	        });
        }

        checkAd();
        /// Stomp 초기화
//        connectStomp();
        connectAndReTryStomp();

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
        dragGestureInit = 0.0;
        dragGestureDistance = 0.0;

        if (widget.isP2P != null && widget.isP2P == true) {
            getMyNick();
        } else {
            getMessageList();
        }
    }

    void _initState() async {
        await chatRoomNoticeInfoProvider.getNoticeList(chatInfo.chatIdx);
    }

    @override
    void dispose() {
	    // App Lifecycle observer 해제
	    WidgetsBinding.instance.removeObserver(this);

	    // 서비스 모두 중지
	    stopAllService();

        super.dispose();
    }

    /*
     * @author : hk
     * @date : 2020-01-14
     * @description : 현재 페이지 실행중인 서비스 모두 중지
     */
    void stopAllService() async {
	    // 비콘 중지
	    HwaBeacon().stopAdvertising();

	    // WS 재 연결 타이머 중지
	    if(_wsTimer != null && _wsTimer.isActive) _wsTimer.cancel();

	    // WS 중지
	    s.unsubscribe(topic: "/sub/danhwa/" + chatInfo.chatIdx.toString());
	    s.disconnect();
    }

    /*
     * @author : hk
     * @date : 2020-01-10
     * @description : 사용자가 프로필 이미지를 가지고있는지 체크 - 사용자 채팅 올라오면 이미지 보여줄때 사용
     */
    bool isExistUserProfileImg(int userIdx) {
    	if(profileImgExistUserSet != null){
    		if(profileImgExistUserSet.contains(userIdx)) return true;
    		else return false;
	    } else {
    		return false;
	    }
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : 입장 시 기존 Advertising Stop, 현재 Ad start
    */
    void checkAd() async {
    	if(Constant.USER_IDX == chatInfo.createUserIdx){
		    bool advertising = await HwaBeacon().isAdvertising();

		    if (advertising) {
			    await HwaBeacon().stopAdvertising();
			    await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
		    }
		    else
			    await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
	    }
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : Advertising Stop/Start
    */
    void advertiseChange() async {
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

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 화면 입장 후 메세지/유저 리스트 받아오기, 가공
    */
    getMessageList() async {
        // 단화방 생성 시
        if (widget.isCreated != null && widget.isCreated) {
            joinedUserNow.add(
                ChatJoinInfo(
                    joinType: "BLE_JOIN",
                    userIdx: chatInfo.createUser.userIdx,
                    userNick: chatInfo.createUser.nick,
	                profilePictureIdx: chatInfo.createUser.profilePictureIdx
                )
            );
        }

        // 최근 메시지에 대해 유튜브, 프로필 이미지 체크 수행
        for (var recentMsg in recentMessageList) {
	        if(recentMsg != null && recentMsg.message != null) {
	        	checkYoutubeAndSetVideo(recentMsg);
	        	checkAndSetProfileImg(recentMsg);

		        messageList.add(recentMsg);
	        }
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
     * @description : 자신의 닉네임 얻어오기 (TODO 임시)
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
    Future<bool> connectStomp() async {
        // connect to MsgServer
        s = StompClient(Constant.CHAT_SERVER_WS, (e, e1){
			developer.log("# WS. StompClient error");
			return false;
        },
        onDone: (){
	        developer.log("# WS connectStomp. StompClient onDone");
	        if(mounted) {
		        setState(() {
			        isWsConnected = false;
		        });
	        }
	        connectAndReTryStomp();
        });

        await s.connectWebSocket();
        s.connectStomp();

        // subscribe topic
        s.subscribe(topic: "/sub/danhwa/" + chatInfo.chatIdx.toString(), roomIdx: chatInfo.chatIdx.toString(), userIdx: Constant.USER_IDX.toString()).stream.listen((HashMap data) =>
		        messageReceived(data),
            onDone: () {
                developer.log("# WS Listen Done");
            },
            onError: (error) {
                developer.log("# WS Listen Error $error");
            }
        );

        if(mounted) {
	        setState(() {
		        isWsConnected = true;
	        });
        }

        return true;
    }

    /*
     * @author : hk
     * @date : 2020-01-13
     * @description : WS 연결 및 재시도
     */
    void connectAndReTryStomp() async {
    	developer.log("## connectAndReTryStomp.");

    	bool connected = await connectStomp();

	    developer.log("## connectAndReTryStomp. connected: $connected");

	    // 연결 실패하면 일정시간 후 재연결 시도
    	if(connected == false){
		    _wsTimer = Timer.periodic(Duration(milliseconds: wsReconnectDelay), (timer) async {
			    bool connected = await connectStomp();
			    if(connected) {
				    timer.cancel();
			    }
		    });
	    }
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 메세지 수신 후 처리
    */
    void messageReceived(HashMap data) async {
	    ChatMessage message = ChatMessage.fromJSON(json.decode(data['contents']));

        developer.log("# messageReceieved : " + json.decode(data['contents']).toString());

        // 프로필 이미지 체크
	    checkAndSetProfileImg(message);

        // TODO 입장한 사용자가 프로필 이미지 있으면 profileImgExistUserSet 에 userIdx 넣어주기, (채팅방을 아예 나갈때도 빼주기?)
        if (message.chatType == "ENTER") {
            joinedUserNow.add(
                ChatJoinInfo(
                    joinType: "BLE_JOIN",
                    userIdx: message.senderIdx,
                    userNick: message.nickName
                )
            );

            // 입장한 사용자 프로필 이미지 있으면 profileImgExistUserSet 에 추가
	        if(message.profileImgUri != null) profileImgExistUserSet.add(message.senderIdx);

        } else if ((message.chatType == "IMAGE" || message.chatType == "VIDEO")  && message.senderIdx == Constant.USER_IDX) {
            // 업로드 완료된 항목 삭제
            for(var i=0; i<uploadingImageCount; i++) {
                if (messageList[i].uploaded == true) {
                    messageList.removeAt(i);
                    uploadingImageCount --;
                }
            }
        }

        // youtube 체크
        checkYoutubeAndSetVideo(message);

        messageList.insert(uploadingImageCount, message);

        setState(() {});
    }

    /*
     * @author : hk
     * @date : 2020-01-11
     * @description : 프로필 이미지 있는 사용자는 메시지에 사용자 프로필 경로 설정
     */
    void checkAndSetProfileImg(ChatMessage message){
	    if(message != null && message.profileImgUri == null && message.senderIdx != null){
		    String profileImgUri;
		    bool existProfileImg = isExistUserProfileImg(message.senderIdx);
		    if(existProfileImg) {
		    	profileImgUri = Constant.getUserProfileImgUri(message.senderIdx);
			    message.profileImgUri = profileImgUri;
		    }
	    }
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

			    if(videoId != null){
				    YoutubePlayerController _controller = YoutubePlayerController(
					    initialVideoId: videoId,
					    flags: YoutubePlayerFlags(
						    autoPlay: true,
					    ),
				    );

				    String thumbnailUrl = YoutubePlayer.getThumbnail(videoId: videoId);

				    YoutubePlayer video = YoutubePlayer(controller: _controller, thumbnailUrl: thumbnailUrl, showVideoProgressIndicator: true, onReady: (){

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
    void thumbnailMessage(dynamic imgFile, GaugeDriver gaugeDriver) {
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
	    dynamic thumbNailFile;

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

                thumbNailFile = imageThumbnailString;
                thumbnailMessage(imageThumbnailString, gaugeDriver);
//                thumbNailFile = File.fromRawPath(imageThumbnailString);
            } else {
                thumbNailFile = contentsFile;
                thumbnailMessage(thumbNailFile, gaugeDriver);
            }

            uploadingImageCount ++;

		    // 파일 업로드 API 호출
		    Response response = await CallApi.fileUploadCall(
				    url: "/api/v2/chat/share/file"
				    , filePath: contentsFile.path
				    , paramMap: param
				    , contentsType: mimeStr
				    , onSendProgress: (int sent, int total){

			    for(var i=0; i<uploadingImageCount; i++) {
			        if (fileType == "video") {
                        if (messageList[i].thumbnailFile == thumbNailFile) {
                            messageList[i].gaugeDriver.drive(sent/total);

                            if(sent == total) {
                                messageList[i].uploaded = true;
                            }
                        }
                    } else {
                        if (messageList[i].thumbnailFile.path == thumbNailFile.path) {
                            messageList[i].gaugeDriver.drive(sent/total);

                            if(sent == total) {
                                messageList[i].uploaded = true;
                            }
                        }
                    }

				    break;
			    }
		    }, onError: (dynamic e){
			    // TODO 서버 에러일 경우 처리, 파일 크기 30MB 넘었을 경우 "oversize" 찍힘
			    developer.log("########### DioError");
			    developer.log(e.toString());
		    });

		    if(response != null && response.statusCode == 200){
			    await precacheImage(
					    CachedNetworkImageProvider(
							    "https://api.hwaya.net/api/v2/chat/share/file?file_idx=" + response.data["data"].toString() + "&type=SMALL", headers: Constant.HEADER
					    ), context);

			    // 썸네일 URI 전송
			    onSendMessage("https://api.hwaya.net/api/v2/chat/share/file?file_idx=" + response.data["data"].toString() + "&type=SMALL", fileType.toUpperCase());
		    } else {
		        // TODO 에러 처리
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

        chatRoomNoticeInfoProvider.chatNoticeList = <ChatNoticeItem>[];
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
                        fontSize: ScreenUtil().setSp(16)
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
            body: new Builder(
                builder: (context) {
                    return GestureDetector(
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
                                            buildInput(),

                                            /// 하단 메뉴 서비스 추가 시 코드 교체
                                            // Menu
//                                            (isShowMenu && !isFocused ? buildMenu() : Container()),
                                        ],
                                    ),
                                ),

                                // Notification
                                Provider.of<ChatRoomNoticeInfoProvider>(context, listen: true).chatNoticeList.length > 0 ?
                                openedNf ? buildNoticeOpen() : buildNotice()
                                :Container(),

                                // Loading
                                isLoading ? Loading() : Container()
                            ],
                        ),
                        onTap: () {
                            FocusScope.of(context).requestFocus(focusNode);
                        },
                        onPanStart: (DragStartDetails details) {
                            dragGestureInit = details.globalPosition.dx;
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                            dragGestureDistance= details.globalPosition.dx - dragGestureInit;
                        },
                        onPanEnd: (DragEndDetails details) {
                            dragGestureInit = 0.0;
                            if (dragGestureDistance < 0) {
                                Scaffold.of(context).openEndDrawer();
                            } else if (dragGestureDistance > 0) {
                                popPage();
                            }
                        }
                    );
                }
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
        chatRoomNoticeInfoProvider = Provider.of<ChatRoomNoticeInfoProvider>(context, listen: true);

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
                                            chatRoomNoticeInfoProvider.chatNoticeList.length > 0 ?
                                            chatRoomNoticeInfoProvider.chatNoticeList[0].contents
                                            : "",
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: ScreenUtil().setWidth(-0.65),
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
                                        return NoticePage(chatInfo: chatInfo);
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
        if (disable) { textEditingController.text = "관전 사용자는 채팅을 입력 할 수 없습니다 :("; }

        return Container(
            width: double.infinity,
            decoration: new BoxDecoration(
                color: Colors.white
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    isFocused || disable ? chatIconClose() : chatIconOpen(),
                    // Edit text
                    Container(
                        width: disable
                                ? ScreenUtil().setWidth(359)
                                : isFocused
                                    ? ScreenUtil().setWidth(317)
                                    : ScreenUtil().setWidth(230),
                        margin: EdgeInsets.only(
                            top: sameSize*6,
                            bottom: sameSize*6,
                            left: disable ? ScreenUtil().setWidth(8) : 0
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
                                                    enabled: disable ? false : true,
                                                    keyboardType: TextInputType.multiline,
                                                    controller: textEditingController,
                                                    minLines: 1,
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontFamily: "NotoSans",
                                                        fontWeight: FontWeight.w400,
                                                        color: disable ? Color.fromRGBO(39, 39, 39, 0.25) : Color.fromRGBO(39, 39, 39, 1),
                                                        fontSize: ScreenUtil().setSp(15),
                                                        letterSpacing: ScreenUtil().setWidth(-1.15),
                                                    ),
                                                    decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.only(
                                                            left: sameSize*13,
                                                            right: sameSize*9,
                                                            bottom: sameSize*10
                                                        ),
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
                                    InkWell(
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
                                            disable ? null : onSendMessage(textEditingController.text, "TALK");
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
        return disable ? Container() : Container(
            child:
            GestureDetector(
                child: Container(
                    margin: EdgeInsets.only(
                        left: ScreenUtil().setWidth(8),
                        right: ScreenUtil().setWidth(12),
                    ),
                    width: ScreenUtil().setWidth(32),
                    height: ScreenUtil().setWidth(32),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(234, 234, 234, 1),
                        image: DecorationImage(
                            image:AssetImage('assets/images/icon/more.png')
                        ),
                        shape: BoxShape.circle
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
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(0)),
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setWidth(32),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(234, 234, 234, 1),
                                    image: DecorationImage(
                                        image: AssetImage(
                                            /// 하단 메뉴 서비스 추가 시 코드 교체
    //                                    isShowMenu
    //                                        ? 'assets/images/icon/iconAttachClose.png'
    //                                        : 'assets/images/icon/iconAttachMore.png'
                                                'assets/images/icon/iconAttachCard.png'
                                        )
                                    ),
                                shape: BoxShape.circle
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
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setWidth(32),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(234, 234, 234, 1),
                                    image: DecorationImage(
                                        image:AssetImage('assets/images/icon/iconAttachCameraChat.png')
                                    ),
                                    shape: BoxShape.circle
                                )
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
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setWidth(32),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(234, 234, 234, 1),
                                    image: DecorationImage(
                                        image:AssetImage('assets/images/icon/iconAttachPhoto.png')
                                    ),
                                    shape: BoxShape.circle
                                )
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
            title: Text(
                fromCamera ?  "카메라" : "앨범",
                style: TextStyle(
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.w500,
                    fontSize: ScreenUtil().setSp(16),
                ),
            ),
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
                                                fontSize: ScreenUtil().setSp(16),
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
                                                letterSpacing: ScreenUtil().setHeight(-0.33),
                                                fontSize: ScreenUtil().setSp(13),
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
                            letterSpacing: ScreenUtil().setHeight(-0.33),
                            fontSize: ScreenUtil().setSp(13),
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