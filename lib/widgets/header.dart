import 'package:flutter/material.dart';

AppBar header(BuildContext context,
    {bool isAppTitle = false, String titleText, List<Widget> actions}) {
  return AppBar(
    title: Text(
      isAppTitle ? "Klettern" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
    ),
    centerTitle: false,
    backgroundColor: Theme.of(context).primaryColorDark,
    actions: actions,
  );
}
