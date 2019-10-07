import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_discoverer/iot/data_type.dart';

class Sensor {
  String name;
  String serviceUUID;
  String characteristicUUID;
  ReadDataType readDataType;
  WriteDataType writeDataType;
  NotifyDataType notifyDataType;
  BluetoothCharacteristic bluetoothCharacteristic;
  BluetoothDescriptor bluetoothDescriptor;
  dynamic data;
  String dataDescription;

  Sensor(
      {this.name,
      this.serviceUUID,
      this.characteristicUUID,
      this.readDataType,
      this.writeDataType,
      this.notifyDataType,
      this.dataDescription});

  void updateData(List<int> values) {
    switch (readDataType) {
      case ReadDataType.unsigned_integer:
        data = _convertUnsignedIntegerArray(values);
        break;
      case ReadDataType.floating_point:
        data = _convertFloatingPointIntegerArray(values);
        break;
      case ReadDataType.void_type:
        break;
      case ReadDataType.character:
        break;
      case ReadDataType.boolean:
        break;
      case ReadDataType.integer:
        break;
      case ReadDataType.double_floating_point:
        break;
      case ReadDataType.raw_binary_data:
        break;
      case ReadDataType.string:
        break;
      case ReadDataType.float_3d_vector:
        break;
      case ReadDataType.double_3d_vector:
        break;
    }
  }

  num _convertUnsignedIntegerArray(List<int> values) {
    ByteData byteData = ByteData(4);
    for(int i = 0; i < 4; i++) {
      byteData.setUint8(3 - i, values[i]);
    }
    return byteData.getUint32(0);
  }

  num _convertFloatingPointIntegerArray(List<int> values) {

    ByteData byteData = ByteData(4);
    for(int i = 0; i < 4; i++) {
      byteData.setUint8(3 - i, values[i]);
    }
    return byteData.getFloat32(0);
  }
}
