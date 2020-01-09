import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:Hwa/constant.dart';
import 'package:dio/dio.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;


class FullPhoto extends StatelessWidget {
    final String url;
    final Map<String, String> header;

    FullPhoto({Key key, @required this.url, this.header}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return FullPhotoScreen(url: url, header: header);
    }
}

class FullPhotoScreen extends StatefulWidget {
    final String url;
    Map<String, String> header;

    FullPhotoScreen({Key key, @required this.url, this.header}) : super(key: key);

    @override
    State createState() => new FullPhotoScreenState(url: url, header: header);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
	String url;
	Map<String, String> header;

    FullPhotoScreenState({Key key, @required this.url, this.header});

    @override
    void initState() {

    	if(header == null) header = Constant.HEADER;
      downloadFile();
	    super.initState();
    }

   downloadFile() async {
      Dio dio = Dio();
      try {
          var dir = await getApplicationDocumentsDirectory();
          await dio.download(url, "${dir.path}/danhwa.jpg");
          RedToast.toast("이미지를 저장했습니다", ToastGravity.TOP);
          developer.log("이미지를 저장했습니다.");
      } catch (e) {
          developer.log(e);
      }
  }

    @override
    Widget build(BuildContext context) {
        return Dismissible(
            direction: DismissDirection.vertical,
            key: Key('key'),
            onDismissed: (direction) {
                Navigator.of(context).pop();
            },
            child: Container(
                color: Colors.transparent,
//                child: PhotoView(imageProvider: AssetImage(url))

                /// 추후 서버에 이미지 등록시 교체
              child: PhotoView(imageProvider: NetworkImage(url, headers: header, scale: 1.0))
//		            child: ExtendedImage.network(url, headers: header, cache: true, borderRadius: BorderRadius.all(Radius.circular(30.0)))
            )
        );
    }

}