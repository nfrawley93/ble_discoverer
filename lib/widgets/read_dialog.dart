import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_discoverer/iot/convertBLE.dart';
import 'package:ble_discoverer/iot/data_type.dart';

typedef ReadBLECallback = void Function({String text, ReadDataType dataType});

class ReadDialog extends StatefulWidget {
  final ReadBLECallback readBLECallback;
  final BluetoothCharacteristic bluetoothCharacteristic;
  final bool callBackOnly;
  final Function(String receivied) receivedCallback;

  const ReadDialog(
      {Key key,
        this.readBLECallback,
        @required this.bluetoothCharacteristic,
        this.callBackOnly = false, this.receivedCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ReadDialogState();
  }
}

class ReadDialogState extends State<ReadDialog> {
  List<String> _prettyList = List<String>();
  List<String> _dataList = List<String>();

  bool _switchValue = false;
  String _currentItem;

  @override
  void initState() {
    super.initState();

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
        )
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
            _read();
          },
          child: Text("Read"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      )
    ];
  }

  Widget _title() {
    return Title(color: Colors.black, child: Text("Read Message"));
  }

  _read() {
    widget.bluetoothCharacteristic.read().then((value){
      widget.receivedCallback(convertFromIntList(intList: value, dataType: ReadDataType.values[_prettyList.indexOf(_currentItem)]));
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
