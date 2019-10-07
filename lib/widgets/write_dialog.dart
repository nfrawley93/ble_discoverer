import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_discoverer/iot/convertBLE.dart';
import 'package:ble_discoverer/iot/data_type.dart';

typedef WriteBLECallback = void Function({String text, WriteDataType dataType});

class WriteDialog extends StatefulWidget {
  final WriteBLECallback writeBLECallback;
  final BluetoothCharacteristic bluetoothCharacteristic;
  final bool callBackOnly;

  const WriteDialog(
      {Key key,
      this.writeBLECallback,
      @required this.bluetoothCharacteristic,
      this.callBackOnly = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WriteDialogState();
  }
}

class WriteDialogState extends State<WriteDialog> {
  TextEditingController _textEditingController;
  List<String> _prettyList = List<String>();
  List<String> _dataList = List<String>();

  bool _switchValue = false;
  String _currentItem;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();

    _dataList = WriteDataType.values.map((writeData) {
      return writeData.toString();
    }).toList();
    _dataList.forEach((string) {
      _prettyList.add(_prettyText(string));
    });

    _currentItem = _prettyList[0];
  }

  String _prettyText(String oldText) {
    oldText = oldText.substring(oldText.indexOf(".") + 1);
    List<String> strings = oldText.split("_");
    String newString = "";
    strings.forEach((eachString) {
      newString = newString +
          " " +
          eachString.substring(0, 1).toUpperCase() +
          eachString.substring(1);
    });

    print(newString.trim());

    return newString.trim();
  }

  Widget _content() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
          child: _inputField(),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black38)),
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 8, top: 4, bottom: 4),
                  child: DropdownButton<String>(
                      value: _currentItem,
                      isExpanded: true,
                      underline: Container(),
                      items: _prettyList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _currentItem = value.toString();
                        });
                      }))),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Expect Response"),
              Switch.adaptive(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  })
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _actions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FlatButton(
          onPressed: () {
            if (widget.writeBLECallback != null) {
              widget.writeBLECallback(
                  text: _textEditingController.text.toString(),
                  dataType:
                      WriteDataType.values[_prettyList.indexOf(_currentItem)]);
            }

            if (!widget.callBackOnly) {
              _write(convertToIntList(text: _textEditingController.text.toString(), dataType: WriteDataType.values[_prettyList.indexOf(_currentItem)]));
            }
          },
          child: Text("Write"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      )
    ];
  }

  Widget _inputField() {
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          hintText: "Data to send"),
    );
  }

  Widget _title() {
    return Title(color: Colors.black, child: Text("Write Message"));
  }

  _write(List<int> data) {
    widget.bluetoothCharacteristic
        ?.write(data, withoutResponse: !_switchValue)
        ?.then((onValue) {
      if (onValue != null) {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("Response ${onValue.toString()}")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
              child: _title(),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
              child: _content(),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: _actions(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
