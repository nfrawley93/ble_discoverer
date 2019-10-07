import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_discoverer/iot/convertBLE.dart';
import 'package:ble_discoverer/iot/data_type.dart';
import 'package:ble_discoverer/pages/bluetooth_device_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ble_discoverer/widgets/simple_alert_dialog.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _currentlyScanning = false;
  List<BluetoothDevice> _deviceList = List<BluetoothDevice>();
  FlutterBlue _flutterBlue;
  StreamSubscription _bluetoothScanSubscription;
  StreamSubscription<BluetoothState> _bluetoothStateStream;
  StreamSubscription<bool> _bluetoothScanningStream;
  BluetoothState _currentBluetoothState;
  bool _isBluetoothScanning = false;

  @override
  void initState() {
    super.initState();
    _setupBluetooth();

    convertFromIntList(intList: [211,77,212,65], dataType: ReadDataType.floating_point);
  }

  _scanForBluetoothDevices() {
    _bluetoothScanSubscription = _flutterBlue.scan(scanMode: ScanMode.lowLatency).listen((foundDevice) {
      print("${foundDevice.rssi} ${foundDevice.advertisementData.txPowerLevel} ${foundDevice.advertisementData.localName}");
      bool alreadyExists = false;
      for (BluetoothDevice device in _deviceList) {
        if (device.id == foundDevice.device.id) alreadyExists = true;
      }
      if (!alreadyExists) {
        print(foundDevice.advertisementData.serviceData.toString());
        if (foundDevice.device.name == "")
          _deviceList.insert(_deviceList.length, foundDevice.device);
        else
          _deviceList.insert(0, foundDevice.device);
        setState(() {});
      }
    });
  }

  _setupBluetooth() async {
    // On a device with no bluetooth this will immediately throw an PlatformException
    // Thrown through FlutterBlue logging, which we can't change until after
    _flutterBlue = FlutterBlue.instance;

    // Determine whether bluetooth is available
    await _flutterBlue?.isAvailable?.then((onValue) {
      // [onValue] is either true or false based on whether the device has bluetooth
      // capabilities. For simplicity if there is not bluetooth I want to null [_flutterBlue]
      // and show an alertDialog to the user. If [onValue] is true, I set the [LogLevel]
      if (!onValue) {
        _flutterBlue = null;
        showOKDialog(context, "Bluetooth is not available on your device",
            subtitle:
                "This can happen if your device doesn't have bluetooth cababilities.");
      } else {
        // Set the log level for FlutterBlue. [LogLevel.emergency] is the highest
        // meaning you will only see logs in emergency situations.
        _flutterBlue.setLogLevel(LogLevel.emergency);
      }
    });

    // Check if bluetooth is on, if [onValue] is false show popup to user
    _flutterBlue?.isOn?.then((onValue) {
      if (!onValue) {
        showOKDialog(context, "Bluetooth is Off",
            subtitle: "Please turn on bluetooth to continue.");
      }
    });

    // Add a listener to update [_currentBluetoothState]
    _bluetoothStateStream = _flutterBlue?.state?.listen((onValue) {
      setState(() {
        _currentBluetoothState = onValue;
      });
      print("Bluetooth State: $_currentBluetoothState");
    });

    // Add a listener to update [_currentlyScanning]
    _bluetoothScanningStream = _flutterBlue?.isScanning?.listen((onValue) {
      setState(() {
        _isBluetoothScanning = onValue;
      });
      print("Bluetooth Scanning: $_currentlyScanning");
    });
  }

  _onFloatingActionButtonPressed() async {
    // If there is no bluetooth or bluetooth is not on, do nothing
    if (_flutterBlue == null || _currentBluetoothState != BluetoothState.on) {
    } else {
      if (_isBluetoothScanning) {
        _stopBluetoothScanning();
      } else {
        _deviceList.clear();
        if (_bluetoothScanSubscription != null)
          await _bluetoothScanSubscription.cancel().then((onValue) {
            _bluetoothScanSubscription = null;
          });
        _scanForBluetoothDevices();
      }
    }
  }

  _stopBluetoothScanning() async {
    await _flutterBlue?.stopScan();
    await _bluetoothScanSubscription?.cancel();
    _bluetoothScanSubscription = null;
  }

  Text _floatingActionButtonText() {
    return _isBluetoothScanning
        ? Text("STOP",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
        : Text("SCAN",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
  }

  Icon _floatingActionButtonIcon() {
    return _isBluetoothScanning
        ? Icon(Icons.close)
        : Icon(Icons.bluetooth_searching);
  }

  Color _floatingActionButtonColor() {
    return (_flutterBlue == null || _currentBluetoothState != BluetoothState.on)
        ? Colors.grey
        : (_isBluetoothScanning ? Colors.red[800] : Colors.blue[800]);
  }

  double _floatingActionButtonElevation() {
    return (_flutterBlue == null || _currentBluetoothState != BluetoothState.on)
        ? 0
        : 6;
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 8),
      child: FloatingActionButton.extended(
        label: _floatingActionButtonText(),
        icon: _floatingActionButtonIcon(),
        backgroundColor: _floatingActionButtonColor(),
        elevation: _floatingActionButtonElevation(),
        highlightElevation: _floatingActionButtonElevation() * 2,
        onPressed: _onFloatingActionButtonPressed,
        tooltip: 'Scan for devices',
        heroTag: 'scan',
      ),
    );
  }

  Widget _buildListTile({int index}) {
    return InkWell(
      onTap: () {
        _stopBluetoothScanning();

        Navigator.push(
            context,
            PageTransition(
                child: DevicePage(
                  bluetoothDevice: _deviceList[index],
                ),
                type: PageTransitionType.rightToLeft));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
            title: Text(
              _deviceList[index].name,
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text(_deviceList[index].id.id),
            trailing: Icon(Icons.arrow_forward_ios)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: _deviceList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildListTile(index: index),
                  index != _deviceList.length
                      ? _doubleDivider(indent: 8, endIndent: 8)
                      : null
                ],
              );
            }),
        floatingActionButton: _buildFloatingActionButton());
  }

  @override
  void dispose() {
    _bluetoothScanningStream.cancel();
    _bluetoothStateStream.cancel();
    super.dispose();
  }
}
