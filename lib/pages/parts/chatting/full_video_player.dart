import 'package:Hwa/constant.dart';
import 'package:Hwa/constant.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:path_provider/path_provider.dart';


void main() => runApp(FullVideoPlayer());

class FullVideoPlayer extends StatefulWidget {
    final String videoUrl;
    final Map<String, String> header;
    final ChatMessage chatMessage;

    FullVideoPlayer({Key key, this.videoUrl, this.header, this.chatMessage}) : super(key: key);

    @override
    VideoPlayerState createState() => VideoPlayerState(videoUrl: this.videoUrl, header: this.header, chatMessage: chatMessage);
}

class VideoPlayerState extends State<FullVideoPlayer> {
    final String videoUrl;
    Map<String, String> header;
    ChatMessage chatMessage;

    VideoPlayerState({Key key, this.videoUrl, this.header, this.chatMessage});

//    VideoPlayerController _controller;
    IjkMediaController _controller;

    @override
    void initState() {
        super.initState();

        if(header == null) header = Constant.HEADER;

        _controller = IjkMediaController();
        _controller.setIjkPlayerOptions([TargetPlatform.android], createIJKOptions());
    }

    @override
    void dispose() {
        super.dispose();
        _controller.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
                child: buildIjkPlayer(),
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.play_arrow),
                onPressed: () async {
	                developer.log("###### init Param");
	                developer.log(videoUrl);
	                developer.log(chatMessage.toString());
	                developer.log(chatMessage.msgIdx.toString());
	                developer.log(chatMessage.roomIdx.toString());

	                Directory tempDir = await getTemporaryDirectory();
	                String tempPath = tempDir.path;

	                // Video file Path : tempPath/roomIdx_msgIdx_videoFile
                    String videoFilePath = tempPath + "/" + chatMessage.roomIdx.toString() + "_" + chatMessage.msgIdx.toString() + "_videoFile";
                    File videoFile = File(videoFilePath);

                    bool isVideoExist = await videoFile.exists();

                    if(isVideoExist){
                    	// 이미 한번 봐서 파일이 있으면 플레이
	                    var dataSource = DataSource.file(videoFile);
	                    await _controller.setDataSource(dataSource, autoPlay: true);
                    } else {
                    	// 동영상 처음 봄, 다운로드 및 저장, 플레이
	                    SharedPreferences prefs = await Constant.getSPF();
	                    var token = jsonDecode(prefs.getString('userInfo'))['token'].toString();

	                    Dio dio = new Dio();
	                    dio.options.headers['X-Authorization'] = 'Bearer ' + token;

//	                Directory appSupportDir = await getApplicationSupportDirectory();
//	                String appSupportPath = appSupportDir.path;

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

	//						String fileExtension;
	//						try {
	//							response.headers.forEach((String key, List<String> listVal){
	//								if(key == "content-type"){
	//									String contentTypeSum = listVal[0];
	//									String contentType = contentTypeSum.split(";")[0];
	//									fileExtension = contentType.split("/")[1];
	//								}
	//							});
	//						} catch (e) {
	//
	//						}
	//
	//						if(fileExtension != null) {
	//							String newPath = tempPath + "." + fileExtension;
	//							file.rename(newPath);
	//
	//							file = File(newPath);
	//						}

		                    var dataSource = DataSource.file(file);
		                    await _controller.setDataSource(dataSource, autoPlay: true);

	                    }
                    }
                },
            ),
        );
    }


    Widget buildIjkPlayer() {
        return Container(
            // height: 400, // 这里随意
            child: IjkPlayer(
                mediaController: _controller,
            ),
        );
    }
// the option is copied from ijkplayer example
    Set<IjkOption> createIJKOptions() {
        return <IjkOption>[
            IjkOption(IjkOptionCategory.player, "mediacodec", 0),
            IjkOption(IjkOptionCategory.player, "opensles", 0),
            IjkOption(IjkOptionCategory.player, "overlay-format", 0x32335652),
            IjkOption(IjkOptionCategory.player, "framedrop", 1),
            IjkOption(IjkOptionCategory.player, "start-on-prepared", 0),
            IjkOption(IjkOptionCategory.format, "http-detect-range-support", 0),
            IjkOption(IjkOptionCategory.codec, "skip_loop_filter", 48),
        ].toSet();
    }
}
