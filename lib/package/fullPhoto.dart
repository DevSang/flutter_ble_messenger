import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
    final String url;

    FullPhoto({Key key, @required this.url}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return FullPhotoScreen(url: url);
    }
}

class FullPhotoScreen extends StatefulWidget {
    final String url;

    FullPhotoScreen({Key key, @required this.url}) : super(key: key);

    @override
    State createState() => new FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
    final String url;

    FullPhotoScreenState({Key key, @required this.url});

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        /// 추후 서버에 이미지 등록시 교체
//        return Container(child: PhotoView(imageProvider: NetworkImage(url)));
        return Dismissible(
            direction: DismissDirection.vertical,
            key: Key('key'),
            onDismissed: (direction) {
                Navigator.of(context).pop();
            },
            child: Container(
                color: Colors.transparent,
                child: PhotoView(imageProvider: AssetImage(url))
            )
        );
    }

}