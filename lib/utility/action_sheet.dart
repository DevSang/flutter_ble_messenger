import 'package:flutter/cupertino.dart';
import 'dart:developer' as developer;

class ActionSheet extends StatefulWidget {
    static const String routeName = '/cupertino/alert';

    @override
    ActionSheetState createState() => ActionSheetState();
}

class ActionSheetState extends State<ActionSheet> {
    String lastSelectedValue;

    void showDemoDialog({BuildContext context, Widget child}) {
        showCupertinoDialog<String>(
            context: context,
            builder: (BuildContext context) => child,
        ).then((String value) {
            if (value != null) {
                setState(() { lastSelectedValue = value; });
            }
        });
    }

    void showDemoActionSheet({BuildContext context, Widget child}) {
        showCupertinoModalPopup<String>(
            context: context,
            builder: (BuildContext context) => child,
        ).then((String value) {
            if (value != null) {
                setState(() { lastSelectedValue = value; });
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return CupertinoActionSheet(
            title: Text("Cupertino Action Sheet"),
            message: Text("Select any action "),
            actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text("Action 1"),
                    isDefaultAction: true,
                    onPressed: () {
                        developer.log("Action 1 is been clicked");
                    },
                ),
                CupertinoActionSheetAction(
                    child: Text("Action 2"),
                    isDestructiveAction: true,
                    onPressed: () {
                        developer.log("Action 2 is been clicked");
                    },
                )
            ],
            cancelButton: CupertinoActionSheetAction(
                child: Text("Cancel"),
                onPressed: () {
                    Navigator.pop(context);
                },
            ),
        );
    }
}