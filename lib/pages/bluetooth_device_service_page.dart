import 'dart:async';
import 'dart:async' as prefix0;
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_discoverer/iot/convertBLE.dart';
import 'package:ble_discoverer/iot/data_type.dart';
import 'package:ble_discoverer/widgets/read_dialog.dart';
import 'package:ble_discoverer/widgets/write_dialog.dart';
import 'package:page_transition/page_transition.dart';

import 'bluetooth_device_characteristic_properties.dart';

class DeviceServicePage extends StatefulWidget {
  final BluetoothService bluetoothService;

  DeviceServicePage({Key key, @required this.bluetoothService})
      : super(key: key);

  @override
  _DeviceServicePageState createState() => _DeviceServicePageState();
}

class _DeviceServicePageState extends State<DeviceServicePage> {
  List<BluetoothCharacteristic> _bluetoothCharacteristics;
  TextEditingController writeController;
  StreamSubscription _listen;
  List<int> _read;
  GlobalKey scafKey = GlobalKey();
  BuildContext scaffoldContext;

  StreamSubscription<BluetoothDeviceState> _bluetoothDeviceStateStream;
  StreamSubscription<bool> _isDiscoveringServicesStream;

  @override
  void initState() {
    super.initState();
    _bluetoothCharacteristics = widget.bluetoothService.characteristics;
  }

  Widget _buildBluetoothCharacteristicTile({int index}) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: DeviceCharacteristicProperties(
                  properties: _bluetoothCharacteristics[index].properties,
                ),
                type: PageTransitionType.rightToLeft));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                onTap: null,
                onLongPress: null,
                contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                title: Text(
                  "UUID",
                  style: TextStyle(fontSize: 18),
                ),
                isThreeLine: true,
                subtitle: Text(
                    "${_bluetoothCharacteristics[index].uuid.toString()}\n${_bluetoothCharacteristics[index].uuid.toMac()}"),
                trailing: Icon(Icons.arrow_forward_ios)),
            ListTile(
              onTap: null,
              onLongPress: null,
              contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              title: Text(
                "Service UUID",
                style: TextStyle(fontSize: 18),
              ),
              isThreeLine: true,
              subtitle: Text(
                  "${_bluetoothCharacteristics[index].serviceUuid.toString()}\n${_bluetoothCharacteristics[index].serviceUuid.toMac()}"),
            ),
            ListTile(
              onTap: null,
              onLongPress: null,
              contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              title: Text(
                "Secondary Service UUID",
                style: TextStyle(fontSize: 18),
              ),
              isThreeLine: true,
              subtitle: Text(
                  "${_bluetoothCharacteristics[index]?.secondaryServiceUuid?.toString()}\n${_bluetoothCharacteristics[index]?.secondaryServiceUuid?.toMac()}"),
            ),
            ListTile(
              onTap: null,
              onLongPress: null,
              contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              title: Text(
                "Number Descriptors",
                style: TextStyle(fontSize: 18),
              ),
              isThreeLine: true,
              subtitle: Text(
                  "${_bluetoothCharacteristics[index].descriptors.length}"),
            ),
            Container(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _bluetoothCharacteristics[index].properties.write
                    ? RaisedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => WriteDialog(
                                    bluetoothCharacteristic:
                                        _bluetoothCharacteristics[index],
                                  ));
                        },
                        child: Text("WRITE"))
                    : Container(),
                _bluetoothCharacteristics[index].properties.read
                    ? RaisedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => ReadDialog(
                                    bluetoothCharacteristic:
                                        _bluetoothCharacteristics[index],
                                receivedCallback: (text) {
                                  Scaffold.of(scafKey.currentContext)
                                      .showSnackBar(SnackBar(
                                    content: Text("Received $text"),
                                    duration: Duration(seconds: 2),
                                    action: SnackBarAction(label: "CLOSE", onPressed: (){Scaffold.of(context).removeCurrentSnackBar();}),
                                  ));
                                },
                                  ));
                          //convertFromIntList(await _bluetoothCharacteristics[index].read());
                          /*_read = await _bluetoothCharacteristics[index].read();
                          Scaffold.of(scafKey.currentContext)
                              .showSnackBar(SnackBar(
                            content: Text("READ ${_read.toString()}"),
                            duration: Duration(seconds: 2),
                          ));*/
                        },
                        child: Text("READ"))
                    : Container(),
                _bluetoothCharacteristics[index].properties.read
                    ? RaisedButton(
                        onPressed: () async {
                          //print(_bluetoothCharacteristics[index].descriptors[0]);
                          await _bluetoothCharacteristics[index]
                              .setNotifyValue(true);
                          _listen = _bluetoothCharacteristics[index]
                              .value
                              .listen((onData) {
                            Scaffold.of(scafKey.currentContext).showSnackBar(
                                SnackBar(
                                    content: Text("LISTEN ${_read.toString()}"),
                                    duration: Duration(seconds: 4)));
                          });
                        },
                        child: Text("LISTEN"))
                    : Container(),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Column _doubleDivider({Color color, double indent, double endIndent}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Divider(
          height: 0,
          indent: indent,
          endIndent: endIndent,
          color: color == null ? Colors.black45 : color,
        )
      ],
    );
  }

  AppBar _buildExtendedAppbar() {
    return AppBar(
      title: Text("Characteristics"),
      leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
        Navigator.pop(context);
      }),
      centerTitle: true,
      bottom: AppBar(
        backgroundColor: Colors.transparent,
        bottomOpacity: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.bluetoothService.deviceId.id,
          style: TextStyle(fontSize: 14),
        ),
        centerTitle: true,
      ),
    );
  }

  ListView _buildList() {
    scaffoldContext = this.context;
    return ListView.builder(
        key: scafKey,
        itemCount: _bluetoothCharacteristics?.length,
        itemBuilder: (BuildContext context, int index) {
          return _bluetoothCharacteristics != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildBluetoothCharacteristicTile(index: index),
                    index != _bluetoothCharacteristics?.length
                        ? _doubleDivider(indent: 8, endIndent: 8)
                        : null
                  ],
                )
              : null;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildExtendedAppbar(), body: _buildList());
  }

  @override
  void dispose() {
    _bluetoothDeviceStateStream?.cancel();
    _isDiscoveringServicesStream?.cancel();
    super.dispose();
  }
}
