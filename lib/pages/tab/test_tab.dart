import 'package:flutter/material.dart';
import 'dart:io';
import 'package:Hwa/utility/cached_image_utility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ImageTest extends StatefulWidget {
  ImageTest({Key key}) : super(key: key);

  @override
  State createState() => new ImageTestState();
}

class ImageTestState extends State<ImageTest> {
  File imageFile;
  Image imageFromPreferences;

  @override
  void initState() {
    super.initState();
    getTestImg();
  }

  pickTestImg() async {
    imageFile = await CachedImageUtility.pickImageFromGallery();
    saveTestImg(imageFile);
  }

  saveTestImg(File imageFile) {
    CachedImageUtility.saveImageToPreferences(
        imageType: Image_type.test_img,
        imageFile: imageFile,
        fileName: 'test'
    );
  }

  getTestImg () async {
    var tempImg = await CachedImageUtility.loadImageFromPreferences(imageType: Image_type.test_img, fileName: 'test');
    setState(() {
      imageFromPreferences = tempImg;
    });
    print(imageFromPreferences);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

    return new Container(
             child:
             Column (
                 children: [
                   null == imageFromPreferences ?
                      Container() : imageFromPreferences,
                   Container(
                     width: ScreenUtil().setWidth(150),
                     height: ScreenUtil().setHeight(150),
                     decoration: BoxDecoration(
                         color: Color.fromRGBO(107, 107, 107, 1)
                     ),
                     child: FlatButton(
                         onPressed:(){
                           pickTestImg();
                         }
                     ),
                   ),
                   Container(
                     width: ScreenUtil().setWidth(150),
                     height: ScreenUtil().setHeight(150),
                     decoration: BoxDecoration(
                         color: Color.fromRGBO(10, 10, 50, 1)
                     ),
                     child: FlatButton(
                         onPressed:(){
                           getTestImg();
                         }
                     ),
                   ),
                 ]
        )
    );
  }
}