class Validator{
  String validateUserName(String userName) {
    if (userName.length >= 10) {
      return '닉네임은 10자리';
    }
    return null;
    }
  }

