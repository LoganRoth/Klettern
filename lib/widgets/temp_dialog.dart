import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void tempDialog({
  BuildContext context,
  String button1,
  String button2 = 'Cancel',
  String title,
  String content,
  Function button1Action,
  Function button2Action,
  bool oneButton = false,
}) {
  if (button1Action == null) {
    button1Action = nullFunction;
  }
  if (button2Action == null) {
    button2Action = nullFunction;
  }
  showDialog(
    context: context,
    builder: (BuildContext ctx) => Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              if (!oneButton)
                CupertinoDialogAction(
                  child: Text(button2),
                  onPressed: () {
                    button2Action();
                    Navigator.of(ctx).pop();
                  },
                ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(button1),
                onPressed: () {
                  button1Action();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          )
        : AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              if (!oneButton)
                FlatButton(
                  child: Text(button2),
                  onPressed: () {
                    button2Action();
                    Navigator.of(ctx).pop();
                  },
                ),
              FlatButton(
                child: Text(button1),
                onPressed: () {
                  button1Action();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
  );
}

void nullFunction() {}
