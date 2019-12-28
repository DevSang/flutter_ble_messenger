import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
    Widget build(BuildContext context) {
        return Positioned(
            child: Container(
                child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
                color: Colors.white.withOpacity(0.8),
            )
        );
    }
}