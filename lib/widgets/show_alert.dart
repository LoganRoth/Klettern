import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// TODO replace with Flushbar

Widget showAlert(
    BuildContext context, String warning, Function warningNullSetter) {
  if (warning != null) {
    Timer(Duration(seconds: 2), () {
      warningNullSetter();
    });
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      color: Colors.red,
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.error_outline),
          ),
          Expanded(
            child: AutoSizeText(
              warning,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                warningNullSetter();
              },
            ),
          )
        ],
      ),
    );
  }
  return SizedBox(
    height: 0,
  );
}
