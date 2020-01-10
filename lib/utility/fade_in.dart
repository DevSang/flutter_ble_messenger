import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeIn extends StatelessWidget {
    final double delay;
    final Widget child;

    FadeIn(this.delay, this.child);

    @override
    Widget build(BuildContext context) {
        final tween = MultiTrackTween([
            Track("opacity").add(Duration(milliseconds: 300), Tween(begin: 0.0, end: 1.0,)),
        ]);

        return ControlledAnimation(
            delay: Duration(milliseconds: (300 * delay).round()),
            duration: tween.duration,
            tween: tween,
            child: child,
            builderWithChild: (context, child, animation) => Opacity(
                opacity: animation["opacity"],
                child: child
            ),
        );
    }
}