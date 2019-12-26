import 'package:Hwa/data/models/chat_count_user.dart';
import 'dart:collection';

class ImageData {
    final String value;
    final String expiration;
    ImageData({this.value, this.expiration});

    ImageData.fromJson(Map<String, dynamic> json)
        : value = json['value'],
            expiration = json['expiration'];

    Map<String, dynamic> toJson() => {
        'value': value,
        'expiration': expiration
    };
}