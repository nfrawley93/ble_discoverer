import 'dart:async';
import 'dart:async' as prefix0;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_discoverer/pages/bluetooth_device_service_page.dart';
import 'package:page_transition/page_transition.dart';

class DevicePage extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;

  DevicePage({Key key, @required this.bluetoothDevice}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<BluetoothService> _bluetoothServices;

  StreamSubscription<BluetoothDeviceState> _bluetoothDeviceStateStream;
  BluetoothDeviceState _bluetoothDeviceState;
  StreamSubscription<bool> _isDiscoveringServicesStream;
  bool _isDiscoveringServices = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _connectToDevice() async {
    _bluetoothServices?.clear();
    widget.bluetoothDevice.connect(autoConnect: true,timeout: Duration(seconds: 10)).catchError(
      (error) {
        setState(() {
          print("TIMEOUT");
        });
      },
    ).whenComplete(() {
      _addListeners();
      _discoverServices();
    });
  }

  _addListeners() {
    _bluetoothDeviceStateStream = widget.bluetoothDevice.state.listen((onData) {
      setState(() {
        _bluetoothDeviceState = onData;
        print("Bluetooth Device State: $_bluetoothDeviceState");
      });
    });

    _isDiscoveringServicesStream =
        widget.bluetoothDevice.isDiscoveringServices.listen((onData) {
      setState(() {
        _isDiscoveringServices = onData;
        print("Bluetooth Discovering Services: $_isDiscoveringServices");
      });
    });
  }

  Future<void> _disconnectFromDevice() async {
    widget.bluetoothDevice.disconnect();
  }

  _discoverServices() async {
    _bluetoothServices = await widget.bluetoothDevice.discoverServices();
    setState(() {});
  }

  Text _floatingActionButtonText() {
    switch (_bluetoothDeviceState) {
      case BluetoothDeviceState.disconnected:
        return Text("CONNECT",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
        break;
      case BluetoothDeviceState.connecting:
        return Text("CONNECTING",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
        break;
      case BluetoothDeviceState.connected:
        switch (_isDiscoveringServices) {
          case true:
            return Text("DISCOVERING",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
            break;
          case false:
            return Text("DISCONNECT",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
            break;
        }
        break;
      case BluetoothDeviceState.disconnecting:
        return Text("DISCONNECTING",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
        break;
    }

    if (_bluetoothDeviceState == null)
      return Text("CONNECT",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));

    return Text("",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
  }

  Icon _floatingActionButtonIcon() {
    switch (_bluetoothDeviceState) {
      case BluetoothDeviceState.disconnected:
        return Icon(Icons.bluetooth);
        break;
      case BluetoothDeviceState.connecting:
        return Icon(Icons.sync);
        break;
      case BluetoothDeviceState.connected:
        switch (_isDiscoveringServices) {
          case true:
            return Icon(Icons.search);
            break;
          case false:
            return Icon(Icons.close);
            break;
        }
        break;
      case BluetoothDeviceState.disconnecting:
        return Icon(Icons.bluetooth_disabled);
        break;
    }

    if (_bluetoothDeviceState == null) return Icon(Icons.bluetooth);

    return Icon(null);
  }

  Color _floatingActionButtonColor() {
    switch (_bluetoothDeviceState) {
      case BluetoothDeviceState.disconnected:
        return Colors.blue[800];
        break;
      case BluetoothDeviceState.connecting:
        return Colors.green;
        break;
      case BluetoothDeviceState.connected:
        switch (_isDiscoveringServices) {
          case true:
            return Colors.green;
            break;
          case false:
            return Colors.red[800];
            break;
        }
        break;
      case BluetoothDeviceState.disconnecting:
        return Colors.grey;
        break;
    }

    if (_bluetoothDeviceState == null) return Colors.blue[800];

    return Colors.black;
  }

  _onFloatingActionButtonPressed() async {
    switch (_bluetoothDeviceState) {
      case BluetoothDeviceState.disconnected:
        setState(() {
          _bluetoothDeviceState = BluetoothDeviceState.connecting;
          _connectToDevice();
        });
        break;
      case BluetoothDeviceState.connecting:
        break;
      case BluetoothDeviceState.connected:
        setState(() {
          _disconnectFromDevice();
        });
        break;
      case BluetoothDeviceState.disconnecting:
        break;
    }

    if (_bluetoothDeviceState == null) {
      setState(() {
        _bluetoothDeviceState = BluetoothDeviceState.connecting;
        _connectToDevice();
      });
    }

    return null;
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 8),
      child: FloatingActionButton.extended(
        label: _floatingActionButtonText(),
        icon: _floatingActionButtonIcon(),
        backgroundColor: _floatingActionButtonColor(),
        onPressed: _onFloatingActionButtonPressed,
        tooltip: 'Scan for devices',
        heroTag: 'scan',
      ),
    );
  }

  Widget _buildBluetoothServiceTile({int index}) {
    return InkWell(
      onTap: () {

        Navigator.push(
            context,
            PageTransition(
                child: DeviceServicePage(
                  bluetoothService: _bluetoothServices[index],
                ),
                type: PageTransitionType.rightToLeft));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                    "${_bluetoothServices[index].uuid.toString()}\n${_bluetoothServices[index].uuid.toMac()}"),
                trailing: Icon(Icons.arrow_forward_ios)),
            ListTile(
                onTap: null,
                onLongPress: null,
                contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                title: Text(
                  "Number Characteristics",
                  style: TextStyle(fontSize: 18),
                ),
                isThreeLine: true,
                subtitle: Text(
                    "${_bluetoothServices[index].characteristics.length}")),
            ListTile(
                onTap: null,
                onLongPress: null,
                contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                title: Text(
                  "Number Included Services",
                  style: TextStyle(fontSize: 18),
                ),
                isThreeLine: true,
                subtitle: Text(
                    "${_bluetoothServices[index].includedServices.length}")),
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
      title: Text(widget.bluetoothDevice.name),
      centerTitle: true,
      bottom: AppBar(
        backgroundColor: Colors.transparent,
        bottomOpacity: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.bluetoothDevice.id.id,
          style: TextStyle(fontSize: 14),
        ),
        centerTitle: true,
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
        itemCount: _bluetoothServices?.length,
        itemBuilder: (BuildContext context, int index) {
          return _bluetoothServices != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildBluetoothServiceTile(index: index),
                    index != _bluetoothServices?.length
                        ? _doubleDivider(indent: 8, endIndent: 8)
                        : null
                  ],
                )
              : null;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildExtendedAppbar(),
        body: _buildList(),
        floatingActionButton: _buildFloatingActionButton());
  }

  @override
  void dispose() {
    _bluetoothDeviceStateStream?.cancel();
    _isDiscoveringServicesStream?.cancel();
    super.dispose();
  }
}
