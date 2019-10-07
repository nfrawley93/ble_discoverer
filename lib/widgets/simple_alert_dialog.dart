import 'package:flutter/material.dart';
import 'package:path/path.dart';


AlertDialog _popUpDialog(BuildContext context, String text, {String subtext}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(text),
    content: subtext == null
        ? null
        : Container(
      child: Text(subtext),
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      )
    ],
  );
}

Future<T> showOKDialog<T>(BuildContext context, String text, {String subtitle}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _popUpDialog(context, text, subtext: subtitle);
      });
}

