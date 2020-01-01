import 'dart:convert';

import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_user_info.dart';

class ChatJoinInfo {
    String joinType;				// User Join Type : BLE_JOIN / BLE_OUT / ONLINE
    int userIdx;			        // User Idx
    String userNick;			    // User Nick

    ChatJoinInfo({
        this.joinType
        , this.userIdx
        , this.userNick
    });


    factory ChatJoinInfo.fromJSON (Map<String, dynamic> jsonData) {
        Map<String, dynamic> userVal = json.decode(jsonData['jb_user_data']['value']);

        return ChatJoinInfo (
            joinType : jsonData['join_type'],
            userIdx : jsonData['user_idx'],
            userNick : userVal['nickname'],
        );
    }
}