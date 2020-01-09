import 'package:Hwa/constant.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(FullVideoPlayer());

class FullVideoPlayer extends StatefulWidget {
    final String videoUrl;
    Map<String, String> header;

    FullVideoPlayer({Key key, this.videoUrl, this.header}) : super(key: key);

    @override
    VideoPlayerState createState() => VideoPlayerState();
}

class VideoPlayerState extends State<FullVideoPlayer> {
    final String videoUrl;
    Map<String, String> header;

    VideoPlayerState({Key key, this.videoUrl, this.header});

    VideoPlayerController _controller;

    @override
    void initState() {
        super.initState();

        if(header == null) header = Constant.HEADER;

        _controller = VideoPlayerController.network(widget.videoUrl)
            ..initialize().then((_) {
                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                setState(() {});
            });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Video Demo',
            home: Scaffold(
                body: Center(
                    child: _controller.value.initialized
                        ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                    )
                        : Container(),
                ),
                floatingActionButton: FloatingActionButton(
                    onPressed: () {
                        setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                        });
                    },
                    child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                ),
            ),
        );
    }

    @override
    void dispose() {
        super.dispose();
        _controller.dispose();
    }
}
