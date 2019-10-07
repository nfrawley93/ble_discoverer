import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_discoverer/iot/data_type.dart';
import 'package:ble_discoverer/iot/default.dart';
import 'package:ble_discoverer/iot/rapid_iot_kit.dart';

class DevicePage extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;

  DevicePage({Key key, @required this.bluetoothDevice}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage>
    with SingleTickerProviderStateMixin {
  RapidIOTKit testKit = DefaultKits.defaultKit;
  List<BluetoothService> _services;
  bool _connected = false;
  bool _connecting = false;
  bool _servicesLoaded = false;
  BluetoothCharacteristic testing;
  Duration updateFrequency = Duration(milliseconds: 250);
  Timer refreshTimer;
  int updateIndex = 0;
  bool currentlyReading = false;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  _updateData() async {
    refreshTimer = Timer.periodic(updateFrequency, (timer) {
      if (testKit != null) {
        if (testKit.sensors != null) {
          if (!currentlyReading) {
            if (testKit.sensors[updateIndex].bluetoothCharacteristic != null) {
              currentlyReading = true;
              testKit.sensors[updateIndex].bluetoothCharacteristic
                  .read()
                  .then((value) {
                setState(() {
                  testKit.sensors[updateIndex].updateData(value);
                  currentlyReading = false;
                  updateIndex++;
                  if (updateIndex >= testKit.sensors.length) updateIndex = 0;
                });
              });
            }
          }
        }
      }
    });
  }

  _discoverServices() async {
    _services = await widget.bluetoothDevice.discoverServices();
    _servicesLoaded = true;

    _services.forEach((service) {
      String serviceUUID = service.uuid.toString();
      testKit.sensors.forEach((sensor) {
        if (sensor.serviceUUID == serviceUUID) {
          service.characteristics.forEach((characteristic) {
            if (sensor.characteristicUUID == characteristic.uuid.toString()) {
              sensor.bluetoothCharacteristic = characteristic;
            }
          });
        }
      });
    });
  }

  Future<void> _connectToDevice() async {
    _connecting = true;
    setState(() {});
    widget.bluetoothDevice
        .connect(timeout: Duration(seconds: 10))
        .catchError(
          (error) {},
        )
        .whenComplete(() {
      _connected = true;
      _connecting = false;
      setState(() {
        _discoverServices();
      });
    });
  }

  Future<void> _disconnectFromDevice() async {
    widget.bluetoothDevice.disconnect().whenComplete(() {
      _connected = false;
      setState(() {});
    });
  }

  _showDialog(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _popUpDialog(text);
        });
  }

  AlertDialog _popUpDialog(String text) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(text),
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

  Widget _buildCard(String title, String subtitle) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16),
                child: Text(title,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ),
              Padding(
                  padding:
                      EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
                  child: Text(subtitle))
            ],
          ),
        ),
      ),
    );
  }

  Container _buildListView() {
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: testKit.sensors.length,
          itemBuilder: (context, index) {
            if (_servicesLoaded == false) {
              return null;
            }
            bool isTrailingEmpty = false;
            if (testKit.sensors[index].dataDescription == null)
              isTrailingEmpty = true;

            if (!isTrailingEmpty) {
              return _buildCard(
                  testKit.sensors[index].name,
                  testKit.sensors[index].data.toString() +
                      " ${testKit.sensors[index]?.dataDescription?.toString()}");
            } else {
              return _buildCard(testKit.sensors[index].name,
                  testKit.sensors[index].data.toString());
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.bluetoothDevice.name),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (!currentlyReading) {
                  testKit.sensors
                      .singleWhere((element) {
                        if (element.name == "RGB LED") {
                          currentlyReading = true;
                          return true;
                        }
                        return false;
                      })
                      ?.bluetoothCharacteristic
                      ?.write([7, 0, 0, 0])
                      ?.whenComplete(() {
                        currentlyReading = false;
                      });
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.remove_circle,
                color: Colors.red,
              ),
              onPressed: () {
                if (!currentlyReading) {
                  testKit.sensors
                      .singleWhere((element) {
                        if (element.name == "RGB LED") {
                          currentlyReading = true;
                          return true;
                        }
                        return false;
                      })
                      ?.bluetoothCharacteristic
                      ?.write([0, 0, 0, 0])
                      ?.whenComplete(() {
                        currentlyReading = false;
                      });
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.remove_circle,
                color: Colors.green,
              ),
              onPressed: () {
                if (!currentlyReading) {
                  testKit.sensors
                      .singleWhere((element) {
                        if (element.name == "RGB LED") {
                          currentlyReading = true;
                          return true;
                        }
                        return false;
                      })
                      ?.bluetoothCharacteristic
                      ?.write([1, 0, 0, 0])
                      ?.whenComplete(() {
                        currentlyReading = false;
                      });
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.remove_circle,
                color: Colors.blue[800],
              ),
              onPressed: () {
                if (!currentlyReading) {
                  testKit.sensors
                      .singleWhere((element) {
                        if (element.name == "RGB LED") {
                          currentlyReading = true;
                          return true;
                        }
                        return false;
                      })
                      ?.bluetoothCharacteristic
                      ?.write([2, 0, 0, 0])
                      ?.whenComplete(() {
                        currentlyReading = false;
                      });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () {
                if (!currentlyReading) {
                  testKit.sensors
                      .singleWhere((element) {
                        if (element.name == "RGB LED") {
                          currentlyReading = true;
                          return true;
                        }
                        return false;
                      })
                      ?.bluetoothCharacteristic
                      ?.write([3, 0, 0, 0])
                      ?.whenComplete(() {
                        currentlyReading = false;
                      });
                }
              },
            ),
          ],
        ),
        body: Container(
          child: _buildListView(),
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: FloatingActionButton.extended(
              label: _connecting
                  ? Text("CONNECTING",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                  : (_connected
                      ? Text("DISCONNECT",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600))
                      : Text("CONNECT",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600))),
              icon: _connecting
                  ? Icon(Icons.sync)
                  : (_connected ? Icon(Icons.close) : Icon(Icons.bluetooth)),
              backgroundColor: _connecting
                  ? Colors.green
                  : (_connected ? Colors.red[800] : Colors.blue[800]),
              onPressed: () {
                if (!_connecting) {
                  if (_connected) {
                    _disconnectFromDevice();
                    refreshTimer.cancel();
                  } else {
                    _services?.clear();
                    _connectToDevice();
                  }
                }
              },
              tooltip: 'Scan for devices',
              heroTag: 'scan',
            )));
  }

  @override
  void dispose() {
    if (refreshTimer?.isActive == true) refreshTimer.cancel();
    if (_connected) _disconnectFromDevice();
    super.dispose();
  }
}
