import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:async/async.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';


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
    final AsyncMemoizer<bool> _memorizer = AsyncMemoizer();                 // memorizer
    final DefaultCacheManager defaultCacheManager = DefaultCacheManager();  // 캐시 매니저

    final String videoUrl;
    ChatMessage chatMessage;
    VideoPlayerState({Key key, this.videoUrl, this.chatMessage});
    VideoPlayerController _controller;
    String positionTime;
    String durationTime;
    bool _showController;
    double dragGestureInit;
    double dragGestureDistance;

    bool showDownloadBtn = false;   // 다운로드 버튼 보여줄지 여부

    File videoFile;     // 비디오 파일
    String vExtension;  // 온라인에서 받은 파일의 최종 확장자

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
        return this._memorizer.runOnce(() async {
        	try {
        		// 캐시에서 파일 검색
		        FileInfo vFileInfo = await defaultCacheManager.getFileFromCache(videoUrl);

		        if(vFileInfo != null){
	                // 이미 한번 봐서 다운로드된 파일이 있으면 플레이
	                _controller = VideoPlayerController.file(vFileInfo.file);
	                showDownloadBtn = true;
	                videoFile = vFileInfo.file;
                } else {
	                // 동영상 처음 봄, 다운로드 및 저장, 플레이
	                Dio dio = await CallApi.getDio();

	                dio.options.responseType = ResponseType.bytes;

	                // TODO 파일 다운로드 중지에 사용 - 파일 다운로드중에 중지 처리 가능, 중지 및 후처리
	                CancelToken cancelToken = CancelToken();
	                Response response = await dio.get(videoUrl, cancelToken: cancelToken, onReceiveProgress: (received, total){
	                	// TODO 프로그레스 보여주기
		                developer.log("$received : $total");
	                });

	                if(response.statusCode == 200){
		                // 이미지 확장자 얻기 (from response header)
		                getExtension(response);

		                List<int> intList = response.data;
		                Uint8List videoData = Uint8List.fromList(intList);

		                // 동영상 캐시 10일
		                await defaultCacheManager.putFile(videoUrl, videoData, maxAge: const Duration(days: 10), fileExtension: vExtension);

		                FileInfo vFileInfo = await defaultCacheManager.getFileFromCache(videoUrl);

		                _controller = VideoPlayerController.file(vFileInfo.file);
		                showDownloadBtn = true;
		                videoFile = vFileInfo.file;
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

    /*
     * @author : hs
     * @date : 2020-01-12
     * @description : 플레이어 바 시간 셋팅
     */
    String getTime(int minutes, int seconds) {
        String _stringTime;
        String _stringMinutes;
        String _stringSeconds;

        _stringMinutes = minutes < 10 ? '0' + minutes.toString() : minutes.toString();
        _stringSeconds = seconds < 10 ? '0' + seconds.toString() : seconds.toString();
        _stringTime = _stringMinutes + ":" + _stringSeconds;

        return _stringTime;
    }

    /*
     * @author : hk
     * @date : 2020-01-12
     * @description : 파일 확장자 얻기
     */
    void getExtension(Response response){
	    try {
		    String disposition = response.headers.value("content-disposition");

		    String fileName = disposition
				    .split(";")[1]
				    .split("=")[1].trim()
				    .replaceAll('"', '')
				    .replaceAll(" ", "_");

		    vExtension = fileName.substring(fileName.lastIndexOf(".") + 1, fileName.length);

		    developer.log("## FullVideoPlayer. vExtension : $vExtension");
	    } catch (e) {
	    	print(e);
		    vExtension = "mp4";
	    }
    }

    /*
     * @author : hk
     * @date : 2020-01-12
     * @description : 동영상 다운로드, TODO 현재 다운로드 파일명이 UUID 형태, 조금 난잡함
     */
    void downloadFile() async {
    	if(videoFile != null){
    		int fileLength = await videoFile.length();

		    developer.log("## videoFile download : ${videoFile.path}");
		    developer.log("## videoFile fileLenth : $fileLength");

		    await videoFile.setLastModified(new DateTime.now());

		    bool result = await GallerySaver.saveVideo(videoFile.path);
		    developer.log("## download result: $result.");

		    // TODO 결과에 따라 성공 여부 보여주기, 휴대폰에 저장된 파일의 경로, 갤러리 등 확인 필요, 다운로드 받은 파일의 용량이 늘어남? 확인 필요
		    if(result){
			    setState(() {
				    showDownloadBtn = false;
			    });
		    }
	    } else {
		    developer.log("download fail.");
	    }
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
                        fontSize: ScreenUtil().setSp(16),
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
	            actions: <Widget>[
		            Visibility(
			            child: IconButton(
				            icon: Icon(Icons.file_download),
				            onPressed: () {
					            downloadFile();
				            },
				            color: Colors.white,
			            ),
			            visible: showDownloadBtn,
		            )
	            ],
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
                                                            fontSize: ScreenUtil().setSp(11),
                                                            fontFamily: "NanumSquare",
                                                            fontWeight: FontWeight.w500
                                                        )
                                                    ),
                                                    Text(
                                                        durationTime ?? '',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            letterSpacing: ScreenUtil().setWidth(-0.75),
                                                            fontSize: ScreenUtil().setSp(11),
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