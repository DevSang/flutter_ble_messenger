import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:async/async.dart';
import 'package:photo_view/photo_view.dart';
import 'package:Hwa/constant.dart';
import 'package:dio/dio.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'dart:developer' as developer;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:Hwa/utility/call_api.dart';

/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2020-01-13
 * @description : 사진 전체보기 화면
 */
class FullPhoto extends StatelessWidget {
    final String photoUrl;

    FullPhoto({Key key, @required this.photoUrl}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return FullPhotoScreen(photoUrl: photoUrl);
    }
}

class FullPhotoScreen extends StatefulWidget {
    final String photoUrl;

    FullPhotoScreen({Key key, @required this.photoUrl}) : super(key: key);

    @override
    State createState() => new FullPhotoScreenState(photoUrl: photoUrl);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {

    FullPhotoScreenState({Key key, @required this.photoUrl});

	final AsyncMemoizer<bool> _memorizer = AsyncMemoizer();                 // memorizer
	final DefaultCacheManager defaultCacheManager = DefaultCacheManager();  // 캐시 매니저
    final String photoUrl;
    
    File imageFile;
    String iExtension;
    bool _showMenu;
    double dragGestureInit;
    double dragGestureDistance;

    @override
    void initState() {
	    super.initState();
        _showMenu = false;
    }

    /*
     * @author : hk
     * @date : 2020-01-12
     * @description : 이미지 다운로드, 프로그레스, 캐시 처리
     */
    Future<bool> initPhoto() async {
	    return this._memorizer.runOnce(() async {
		    try {
			    // 캐시에서 파일 검색
			    FileInfo iFileInfo = await defaultCacheManager.getFileFromCache(photoUrl);

			    if(iFileInfo != null){
				    imageFile = iFileInfo.file;
			    } else {
				    // 이미지 처음 봄, 다운로드 및 저장
				    Dio dio = await CallApi.getDio();

				    dio.options.responseType = ResponseType.bytes;

				    // 이미지 다운로드
				    Response response = await dio.get(photoUrl, onReceiveProgress: (received, total){
					    // TODO 프로그레스 보여주기
					    developer.log("$received : $total");
				    });

				    if(response.statusCode == 200){
				    	// 이미지 확장자 얻기 (from response header)
					    getExtension(response);

					    List<int> intList = response.data;
					    Uint8List imgData = Uint8List.fromList(intList);

					    // 이미지 캐시에 저장
					    await defaultCacheManager.putFile(photoUrl, imgData, maxAge: const Duration(days: 10), fileExtension: iExtension);

					    FileInfo iFileInfo = await defaultCacheManager.getFileFromCache(photoUrl);

					    // 이미지 파일 셋팅
					    imageFile = iFileInfo.file;
				    } else {

					    developer.log("### not 200");
					    // TODO 결과에 따라 성공 여부 보여주기

				        return false;
				    }
			    }

			    return true;
		    } catch(e) {
		    	print(e);
			    // TODO 결과에 따라 성공 여부 보여주기
				return false;
		    }
	    });
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

		    developer.log("## FullPhoto. fileName : $fileName");

		    iExtension = fileName.substring(fileName.lastIndexOf(".") + 1, fileName.length);
	    } catch (e) {
		    iExtension = "jpeg";
	    }
    }

    /*
     * @author : hk
     * @date : 2020-01-12
     * @description : 이미지 파일 다운로드(앨범에 저장)
     */
	void downloadFile() async {
		if(imageFile != null){
			int fileLength = await imageFile.length();

			developer.log("## imageFile download : ${imageFile.path}");
			developer.log("## imageFile fileLenth : $fileLength");

			await imageFile.setLastModified(new DateTime.now());

			bool result = await GallerySaver.saveImage(imageFile.path);
			developer.log("## download result: $result.");

			// TODO 결과에 따라 성공 여부 보여주기, 휴대폰에 저장된 파일의 경로, 갤러리 등 확인 필요

		} else {
			developer.log("download fail.");
			// TODO 결과에 따라 성공 여부 보여주기
		}
	}

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<bool>(
	        future: initPhoto(),
		    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                _showMenu = true;
                return Scaffold(
                    body: snapshot.data == true ? GestureDetector(
                        child:  Stack(
                            children: <Widget>[
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    color: Colors.black,
                                    child:
                                    snapshot.data == true
                                        ? Align(
                                        alignment: Alignment.center,
                                        child: PhotoView(
                                            imageProvider: FileImage(imageFile),
                                        )
                                    )
                                        : Positioned.fill(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: const CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                    Color.fromRGBO(76, 96, 191, 1),
                                                )
                                            )
                                        )
                                    ),
                                ),
                                menuSection()
                            ],
                        ),
                        onTap : (){
                            setState(() {
                                _showMenu = !_showMenu;
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
                    )
                    : CircularProgressIndicator()
                );
		    }
        );
    }

    Widget menuSection() {
	    return Positioned(
            top: 0,
            child: Container(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: ScreenUtil().setHeight(90),
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    padding: EdgeInsets.only(
                        right: ScreenUtil().setWidth(8)
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            InkWell(
                                child: Container(
                                    width: ScreenUtil().setWidth(40),
                                    height: ScreenUtil().setWidth(40),
                                    child: Icon(
                                        Icons.arrow_back_ios,
                                        color: Color.fromRGBO(250, 250, 250, 1),
                                    )
                                ),
                                onTap: () {
                                    Navigator.pop(context);
                                },
                            ),

                            InkWell(
                                child: Container(
                                    width: ScreenUtil().setWidth(20),
                                    height: ScreenUtil().setWidth(20),
                                    child: Icon(
                                        Icons.file_download,
                                        color: Color.fromRGBO(250, 250, 250, 1),
                                    )
                                ),
                                onTap: () {
                                    downloadFile();
                                },
                            )
                        ],
                    )
                )
            )
        );
    }
}