import 'package:Hwa/constant.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

void main() => runApp(FullVideoPlayer());

class FullVideoPlayer extends StatefulWidget {
    final String videoUrl;
    Map<String, String> header;

    FullVideoPlayer({Key key, this.videoUrl, this.header}) : super(key: key);

    @override
    VideoPlayerState createState() => VideoPlayerState(videoUrl: this.videoUrl, header: this.header);
}

class VideoPlayerState extends State<FullVideoPlayer> {
    final String videoUrl;
    Map<String, String> header;

    VideoPlayerState({Key key, this.videoUrl, this.header});

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
                    print(videoUrl);
                    await _controller.setNetworkDataSource(videoUrl, headers: header, autoPlay: true);
                    await _controller.play();

                    print(_controller.ijkStatus);

                    _controller.ijkStatusStream.listen(
                        (onData){
                            print(onData);
                        }
                    );
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
