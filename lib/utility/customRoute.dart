import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
    CustomRoute({ WidgetBuilder builder, RouteSettings settings })
        : super(builder: builder, settings: settings);

    @override
    Widget buildTransitions(BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {
        return SlideTransition(
            position: Tween<Offset>(
                begin: const Offset(2.0, 0.0),
                end: Offset.zero,
            ).animate(animation),
            child: child, // child is the value returned by pageBuilder
        );
    }
}