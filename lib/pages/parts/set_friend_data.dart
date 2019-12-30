
import 'package:Hwa/data/models/friend_info.dart';

class SetFriendsData {

    List<FriendInfo> main() {
        List<FriendInfo> friendInfoList = <FriendInfo>[];

        friendInfoList = [
            FriendInfo(
                userIdx: 1,
                nickname: "강희근",
                phone_number: "010-1234-5678",
                profile_picture_idx: null,
                business_card_idx: null,
                user_status: "",
            ),
            FriendInfo(
                userIdx: 2,
                nickname: "나영희",
                phone_number: "010-2156-4375",
                profile_picture_idx: null,
                business_card_idx: null,
                user_status: "",
            ),
            FriendInfo(
                userIdx: 3,
                nickname: "도수정",
                phone_number: "010-7546-8763",
                profile_picture_idx: null,
                business_card_idx: null,
                user_status: "",
            )
        ];



        return friendInfoList;
    }
}