import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:collection';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/image_data.dart';

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
class CachedImageUtility{
  static final today = new DateTime.now();

  static Future<String> getImageFromPreferences(String imageKeyword) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(imageKeyword) ?? null;
  }

  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64.decode(base64String),
      width: ScreenUtil().setWidth(500),
      height: ScreenUtil().setHeight(500)
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }




  static Future<bool> saveImageToPreferences(String imageKeyword, value, int expireSec) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    ImageData imgData = ImageData(
        value: value,
        expiration: 'profile' == imageKeyword ? null : today.add(new Duration(seconds: expireSec)).toString()
    );

    return prefs.setString(imageKeyword, json.encode(imgData.toJson()));
  }


  static Future<Image> loadImageFromPreferences({@required String keyword}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var imgData = await getImageFromPreferences(keyword);
    var jsonImgData = json.decode(imgData);
    DateTime expireDate = DateTime.parse(jsonImgData['expiration']);

    //만료 되면
    if(expireDate.isBefore(today)){
      prefs.remove(keyword);
      return null;
    } else {
      return imageFromBase64String(jsonImgData['value']);
    }
  }





  static pickImageFromGallery() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  static pickImageFromCamera() async {
    return await ImagePicker.pickImage(source: ImageSource.camera);
  }

}
