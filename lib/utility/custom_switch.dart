library custom_switch;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSwitch extends StatefulWidget {
    final bool value;
    final ValueChanged<bool> onChanged;
    final Color activeColor;
    final Color inactiveColor;


    const CustomSwitch({
        Key key,
        this.value,
        this.onChanged,
        this.activeColor,
        this.inactiveColor
    })
    : super(key: key);

    @override
    _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
    Animation _circleAnimation;
    AnimationController _animationController;

    @override
    void initState() {
        super.initState();
        _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 60));
        _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight
        )
        .animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.linear
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        Function scW = ScreenUtil().setWidth;
        Function scH = ScreenUtil().setHeight;

        return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
            return GestureDetector(
                onTap: () {
                    if (_animationController.isCompleted) {
                        _animationController.reverse();
                    } else {
                        _animationController.forward();
                    }
                    widget.value == false
                        ? widget.onChanged(true)
                        : widget.onChanged(false);
                    },
                    child: Container(
                        width: scW(54.0),
                        height: scW(30.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(scW(20.0)),
                            color: _circleAnimation.value == Alignment.centerLeft
                                ? widget.inactiveColor
                                : widget.activeColor
                        ),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: scW(3.0),
                                horizontal: scW(3.0)
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    _circleAnimation.value == Alignment.centerRight
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: scW(12.0),
                                        ),
                                    )
                                    : Container(),
                                    Align(
                                        alignment: _circleAnimation.value,
                                        child: Container(
                                            width: scW(24.0),
                                            height: scW(24.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle, color: Colors.white,
                                            ),
                                        ),
                                    ),
                                    _circleAnimation.value == Alignment.centerLeft
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: scW(12.0),
                                        ),
                                    )
                                    : Container(),
                                ],
                            ),
                        ),
                    ),
                );
            },
        );
    }
}