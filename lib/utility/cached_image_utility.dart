import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-24
 * @description : * About cache image function
 *                1. Convert image to base64, base64 to image
 *                2. Save and load image from shared preference
 *                image type - business card image(BCI)
 *                           - my profile image(MPI)
 *                           - common receive image
 */
class CachedImageUtility {
  static String IMAGE_KEYWORD = "IMAGE";

  static Future<String> getImageFromPreferences(String imageKeyword) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('#prefs : ' + prefs.getString(imageKeyword));
    return prefs.getString(imageKeyword) ?? null;
  }

  static Future<bool> saveImageToPreferences(String imageKeyword, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(imageKeyword, value);
  }

  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Future<File> loadImageFromPreferences(String imageKeyword) async {
    print('#loadImageFromPreferences');
    print('#imageKeyword : ' + imageKeyword);
    getImageFromPreferences(imageKeyword).then((img) {
      print('#loaded Img');
      if (null == img) {
        return null;
      } else {
        return img;
      }
    });

  }

  static pickImageFromGallery() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  static pickImageFromCamera() async {
    return await ImagePicker.pickImage(source: ImageSource.camera);
  }


//  Widget imageFromGallery(Future<File> imageFile) {
//    return FutureBuilder<File>(
//      future: imageFile,
//      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
//        if (snapshot.connectionState == ConnectionState.done &&
//            null != snapshot.data) {
//          //print(snapshot.data.path);
//          saveImageToPreferences(
//              base64String(snapshot.data.readAsBytesSync()));
//          return Image.file(
//            snapshot.data,
//          );
//        } else if (null != snapshot.error) {
//          return Image.asset(
//            "assets/images/profile_img.png",
//            width: ScreenUtil().setWidth(80),
//            height: ScreenUtil().setWidth(80),
//          );
//        } else {
//          return Image.asset(
//            "assets/images/profile_img.png",
//            width: ScreenUtil().setWidth(80),
//            height: ScreenUtil().setWidth(80),
//          );
//        }
//      },
//    );
//  }

}
