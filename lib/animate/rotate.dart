import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';


class Rotate extends StatelessWidget {
    final double delay;
    final Widget child;

    Rotate(this.delay, this.child);

    final tween = MultiTrackTween ([
        Track("rotation").add(Duration(seconds: 6), ConstantTween(0.0)).add(
            Duration(seconds: 6), Tween(begin: 0.0, end: 360 / 2),
            curve: Curves.easeOutSine)
    ]);


    @override
    Widget build(BuildContext context) {

        return ControlledAnimation(
            duration: tween.duration,
            tween: tween,
            builder: (context, animation) {
                return Transform.rotate(
                    angle: animation["rotation"],
                    child: child
                );
            },
        );
    }
}