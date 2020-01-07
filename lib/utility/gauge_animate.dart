import 'package:flutter/material.dart';
import 'package:Hwa/package/gauge/gauge_driver.dart';
import 'package:Hwa/package/gauge/gauge_painter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GaugeAnimate extends StatefulWidget {

    const GaugeAnimate({
        Key key,
        @required this.driver
    }) : super(key: key);

    final GaugeDriver driver;

    @override
    GaugeState createState() => GaugeState();

}

class GaugeState extends State<GaugeAnimate> with SingleTickerProviderStateMixin {

    Animation<double> _animation;
    AnimationController _controller;

    String get _readout => (_animation.value * 100).toStringAsFixed(0) + '%';

    double begin = 0.0;
    double end = 0.0;

    @override
    void initState() {

        super.initState();
        _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 320));
        widget.driver.listen(on);
    }

    void on(dynamic x) => setState(() {
        begin = end;
        end = x;
    });

    final TextStyle _style = TextStyle(
        color: Colors.white,
        fontSize: ScreenUtil().setSp(13),
        fontFamily: "NanumSquare",
        fontWeight: FontWeight.w400,
    );

    @override
    Widget build(BuildContext context) {

        final double _diameter = ScreenUtil().setWidth(45);

        _controller.reset();
        _animation = Tween<double>(begin: begin, end: end).animate(_controller);
        _animation.addStatusListener((status) {
            if (status == AnimationStatus.completed) { begin = end; }
        });

        _controller.forward();

        return AnimatedBuilder(

            animation: _animation,
            builder: (context, widget)  {

                return CustomPaint(

                    foregroundPainter: GaugePainter(percent: _animation.value),
                    child: Container(

                        constraints: BoxConstraints.expand(height: _diameter, width: _diameter),
                        child: Align(

                            alignment: Alignment.center,
                            child: Row(

                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                    Text(_readout, style: _style),
                                ]
                            )
                        )
                    )
                );
            }
        );
    }
}