/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-30
 * @description : UserInfo model
 */

class UserInfo {
    int userIdx;
    String phoneNumber;
    String authNumber;
    String socialCd;
    String socialId;
    int loginFailCnt;
    bool isLock;
    String lastLoginTs;
    String userStatus;
    String regTs;
    String updateTs;
    //Todo : file upload해서 사용할것
    String profileURL;


    UserInfo({
        this.userIdx
        ,this.phoneNumber
        ,this.authNumber
        ,this.socialCd
        ,this.socialId
        ,this.loginFailCnt
        ,this.isLock
        ,this.lastLoginTs
        ,this.userStatus
        ,this.regTs
        ,this.updateTs
        ,this.profileURL
    });

    factory UserInfo.fromJSON (Map<String, dynamic> json) {
        return UserInfo (
            userIdx : json['userIdx'] ?? "",
            phoneNumber : json['phoneNumber'] ?? "",
            authNumber : json['authNumber'] ?? "",
            socialCd : json['socialCd'] ?? "",
            socialId : json['socialId'] ?? "",
            loginFailCnt : json['loginFailCnt'] ?? "",
            isLock : json['isLock'] ?? "",
            lastLoginTs : json['lastLoginTs'] ?? "",
            userStatus : json['userStatus'] ?? "",
            regTs : json['regTs'] ?? "",
            updateTs : json['updateTs'] ?? "",
            profileURL : json['profileURL'] ?? "",
        );
    }

    Map<String, dynamic> toJson() =>
        {
            "userIdx" : userIdx,
            "phoneNumber" : phoneNumber,
            "authNumber" : authNumber,
            "socialCd" : socialCd,
            "socialId" : socialId,
            "loginFailCnt" : loginFailCnt,
            "isLock" : isLock,
            "lastLoginTs" : lastLoginTs,
            "userStatus" : userStatus,
            "regTs" : regTs,
            "updateTs" : updateTs,
            "profileURL" : profileURL,
        };
}
