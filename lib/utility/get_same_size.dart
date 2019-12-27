import 'package:flutter_screenutil/flutter_screenutil.dart';
class GetSameSize {
    double main() {
        double width = ScreenUtil().setWidth(1);
        double height = ScreenUtil().setHeight(1);

        double value = width < height ? width : height;
        return value;
    }
}