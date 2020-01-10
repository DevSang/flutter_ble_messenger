import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:async/async.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/constant.dart';

/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2020-01-10
 * @description : 비디오 플레이어
 */
class FullVideoPlayer extends StatefulWidget {
    final String videoUrl;
    final ChatMessage chatMessage;

    FullVideoPlayer({Key key, this.videoUrl, this.chatMessage}) : super(key: key);

    @override
    VideoPlayerState createState() => VideoPlayerState(videoUrl: this.videoUrl, chatMessage: chatMessage);
}

class VideoPlayerState extends State<FullVideoPlayer> {
    final AsyncMemoizer<bool> _memoizer = AsyncMemoizer();
    final String videoUrl;
    ChatMessage chatMessage;
    VideoPlayerState({Key key, this.videoUrl, this.chatMessage});
    VideoPlayerController _controller;
    String positionTime;
    String durationTime;
    bool _showController;
    double dragGestureInit;
    double dragGestureDistance;

    @override
    void initState() {
        super.initState();
        _showController = true;
    }

    @override
    void dispose() {
        super.dispose();
        if(_controller != null) _controller.dispose();
    }

    /*
     * @author : hk
     * @date : 2020-01-10
     * @description : 동영상 정보 초기화. 로컬에 있으면 바로, 없으면 다운로드 하여 init.
     */
    Future<bool> initVideoPlayer() async {

		/*
		 * @author : hk
		 * @date : 2020-01-10
		 * @description : play - pause 누를때, 버튼 업데이트를 위해 setState 하면
		 *                FutureBuilder 가 initVideoPlayer()를 재 실행
		 *                video init, play 를 다시 누적하여 오류 일으킴
		 *                AsyncMemoizer 사용하여 초기화 결과는 Cache에서 반환
		 */
        return this._memoizer.runOnce(() async {
        	try {
		        Directory tempDir = await getTemporaryDirectory();
		        String tempPath = tempDir.path;

		        // Video file Path : tempPath/roomIdx_msgIdx_videoFile
		        String videoFilePath = tempPath + "/" + chatMessage.roomIdx.toString() + "_" + chatMessage.msgIdx.toString() + "_videoFile";
		        File videoFile = File(videoFilePath);

		        bool isVideoExist = await videoFile.exists();

		        if(isVideoExist){
	                // 이미 한번 봐서 파일이 있으면
	                _controller = VideoPlayerController.file(videoFile);
                } else {
	                // 동영상 처음 봄, 다운로드 및 저장, 플레이
	                SharedPreferences prefs = await Constant.getSPF();
	                var token = jsonDecode(prefs.getString('userInfo'))['token'].toString();

	                Dio dio = new Dio();
	                dio.options.headers['X-Authorization'] = 'Bearer ' + token;

	                // TODO file download 요청 및 진행시 발생하는 에러 처리
	                dio.interceptors.add(InterceptorsWrapper(
			                onRequest:(RequestOptions options) async {
				                // Do something before request is sent
				                developer.log("### onRequest");
				                return options; //continue
			                },
			                onResponse:(Response response) async {
				                // Do something with response data
				                developer.log("### response");
				                return response; // continue
			                },
			                onError: (DioError e) async {
				                // Do something with response error
				                developer.log("### onError");
				                developer.log("### e: ${e.toString()}");
				                return  e;//continue
			                }
	                ));

	                // TODO 파일 다운로드 중지에 사용, 중지 및 후처리
	                CancelToken cancelToken = CancelToken();

	                Response response = await dio.download(videoUrl, videoFilePath, cancelToken: cancelToken, onReceiveProgress: (received, total){
		                developer.log("$received : $total");
	                });

	                if(response.statusCode == 200){
		                // TODO file name을 원본 확장자로...?
		                // TODO => 나중에 파일 다시 볼 때 파일 확장자를 알수가 없음. 추후 필요시 서버와 연동하여 업데이트
		                File file = File(videoFilePath);

		                _controller = VideoPlayerController.file(file);
	                } else {
		                return false;
	                }
                }

		        await _controller.initialize();

                durationTime = getTime(_controller.value.duration.inMinutes, _controller.value.duration.inSeconds);

		        // 비디오가 끝나면 처음으로 돌림
		        _controller.addListener(() async {
                    setState(() {
                        positionTime = getTime(_controller.value.position.inMinutes, _controller.value.position.inSeconds);
                    });


			        if(_controller.value.position == _controller.value.duration){
				        await _controller.seekTo(Duration(seconds: 0, minutes: 0, hours: 0));

				        await _controller.pause();
				        setState(() {});
			        }
		        });

		        await _controller.play();

		        setState(() {});

		        return true;
	        } catch (e) {
		        developer.log(e.toString());
		        return false;
	        }
        }); // memoizer.runOnce
    }

    String getTime(int minutes, int seconds) {
        String _stringTime;
        String _stringMinutes;
        String _stringSeconds;

        _stringMinutes = minutes < 10 ? '0' + minutes.toString() : minutes.toString();
        _stringSeconds = seconds < 10 ? '0' + seconds.toString() : seconds.toString();
        _stringTime = _stringMinutes + ":" + _stringSeconds;

        return _stringTime;
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: _showController
                ? new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                title: Text(
                    chatMessage.nickName + "님의 동영상",
                    style: TextStyle(
                        height: 1,
                        color: Color.fromRGBO(250, 250, 250, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16),
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w400
                    ),
                ),
                leading: new IconButton(
                    icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color.fromRGBO(250, 250, 250, 1),
                        size: ScreenUtil().setWidth(20),
                    ),
                    onPressed: (){
                        Navigator.of(context).pop();
                    }
                ),
                backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                centerTitle: true,
                elevation: 0,
            )
            : new AppBar(
                elevation: 0,
                backgroundColor: Color.fromRGBO(255, 255, 255, 0),
            ),
            body: new Builder(
                builder: (context) {
                    return GestureDetector(
                        child: Container(
                            width: ScreenUtil().setWidth(375),
                            height: ScreenUtil().setHeight(667),
                            child: Stack(
                                children: <Widget>[
                                    // 영상 영역
                                    Center(
                                        child: videoSection()
                                    ),

                                    // 컨트롤러 영역
                                    controllerSection()
                                ],
                            )
                        ),
                        onTap : (){
                            setState(() {
                                _showController = !_showController;
                            });
                        },
                        onPanStart: (DragStartDetails details) {
                            dragGestureInit = details.globalPosition.dy;
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                            dragGestureDistance= details.globalPosition.dy - dragGestureInit;
                        },
                        onPanEnd: (DragEndDetails details) {
                            dragGestureInit = 0.0;
                            if (dragGestureDistance > 0) {
                                Navigator.of(context).pop();
                            }
                        }
                    );
                }
            ),
            backgroundColor: Colors.black,
        );
    }

    Widget videoSection() {
        return FutureBuilder<bool>(
            future: initVideoPlayer(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data == true) {
                    return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller)
                    );
                } else {
                    return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromRGBO(76, 96, 191, 0.7),
                        )
                    );
                }
            }
        );
    }

    Widget controllerSection() {
        return Positioned(
            bottom: 0,
            child: FutureBuilder<bool>(
            future: initVideoPlayer(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data == true) {
                    return AnimatedOpacity(
                        opacity: _showController ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 200),
                        child: Container(
                            width: ScreenUtil().setWidth(375),
                            height: ScreenUtil().setHeight(90),
                            color: Color.fromRGBO(0, 0, 0, 0.6),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                    children: <Widget>[
                                        // Controller
                                        Container(
                                            width: ScreenUtil().setWidth(375),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: ScreenUtil().setWidth(16),
                                            ),
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(10),
                                                bottom: ScreenUtil().setHeight(3),
                                            ),
                                            child: VideoProgressIndicator(
                                                _controller,
                                                allowScrubbing: true,
                                                colors: VideoProgressColors(
                                                    playedColor: Colors.white,
                                                    backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
                                                    bufferedColor: Color.fromRGBO(0, 0, 0, 0.3),
                                                ),
                                            ),
                                        ),

                                        // Controller Time
                                        Container(
                                            width: ScreenUtil().setWidth(375),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: ScreenUtil().setWidth(16),
                                            ),
                                            child:
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                    Text(
                                                        positionTime ?? '',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            letterSpacing: ScreenUtil().setWidth(-0.75),
                                                            fontSize: ScreenUtil.getInstance().setSp(11),
                                                            fontFamily: "NanumSquare",
                                                            fontWeight: FontWeight.w500
                                                        )
                                                    ),
                                                    Text(
                                                        durationTime ?? '',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            letterSpacing: ScreenUtil().setWidth(-0.75),
                                                            fontSize: ScreenUtil.getInstance().setSp(11),
                                                            fontFamily: "NanumSquare",
                                                            fontWeight: FontWeight.w500
                                                        )
                                                    ),
                                                ],
                                            ),
                                        ),

                                        // 재생 버튼
                                        InkWell(
                                            onTap: () {
                                                if(_controller != null){
                                                    setState(() {
                                                        if (_controller.value.isPlaying) {
                                                            _controller.pause();
                                                        } else {
                                                            _controller.play();
                                                        }
                                                    });
                                                }
                                            },
                                            // Display the correct icon depending on the state of the player.
                                            child: Container(
                                                width: ScreenUtil().setWidth(50),
                                                height: ScreenUtil().setWidth(50),
                                                decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: Border.all(
                                                        width: ScreenUtil().setWidth(1),
                                                        color: Colors.white
                                                    ),
                                                    shape: BoxShape.circle
                                                ),
                                                child: Icon(
                                                    _controller == null ? Icons.hourglass_empty : (_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                                                    color: Colors.white,
                                                    size: ScreenUtil().setWidth(35),
                                                )
                                            )
                                        ),
                                    ],
                                )
                            )
                        )
                    );
                } else {
                    return Container();
                }
            })
        );
    }
}