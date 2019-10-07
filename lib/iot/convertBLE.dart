import 'dart:developer';
import 'dart:typed_data';

import 'package:ble_discoverer/iot/data_type.dart';

List<int> convertToIntList({String text, WriteDataType dataType}) {
  switch (dataType) {
    case WriteDataType.void_type:
      log("Data type not implemented");
      print("Converting Void to Int[]");
      break;
    case WriteDataType.character:
      log("Data type not implemented");
      print("Converting Character to Int[]");
      break;
    case WriteDataType.boolean:
      log("Data type not implemented");
      print("Converting Boolean to Int[]");
      break;
    case WriteDataType.integer:
      ByteBuffer buffer = Int8List(4).buffer;
      ByteData bufferData = ByteData.view(buffer);
      bufferData.setInt32(0, int.parse(text));
      List<int> toSend = List<int>();

      for (int i = 3; i >= 0; i--) {
        toSend.add(bufferData.getInt8(i));
      }
      print("Converting Integer to Int[]");
      return toSend;
    case WriteDataType.unsigned_integer:
      ByteBuffer buffer = Uint8List(4).buffer;
      ByteData bufferData = ByteData.view(buffer);
      bufferData.setUint32(0, int.parse(text));
      List<int> toSend = List<int>();

      for (int i = 3; i >= 0; i--) {
        toSend.add(bufferData.getUint8(i));
      }
      print("Converting Unsigned Integer to Int[]");
      return toSend;
    case WriteDataType.floating_point:
      ByteBuffer buffer = Float32List(4).buffer;
      ByteData bufferData = ByteData.view(buffer);
      bufferData.setFloat32(0, double.parse(text));
      List<int> toSend = List<int>();

      for (int i = 3; i >= 0; i--) {
        toSend.add(bufferData.getUint8(i));
      }
      print("Converting Floating Point to Int[]");
      return toSend;
    case WriteDataType.double_floating_point:
      log("Data type not implemented");
      print("Converting Double Floating Point to Int[]");
      break;
    case WriteDataType.raw_binary_data:
      log("Data type not implemented");
      print("Converting Raw Binary to Int[]");
      break;
    case WriteDataType.string:
      print("Converting String to Int[]");
      return text.codeUnits;
    case WriteDataType.float_3d_vector:
      log("Data type not implemented");
      print("Converting Float 3d Vector to Int[]");
      break;
    case WriteDataType.double_3d_vector:
      log("Data type not implemented");
      print("Converting Double 3D Vector to Int[]");
      break;
  }
  return null;
}

String convertFromIntList({List<int> intList, ReadDataType dataType}) {
  switch (dataType) {
    case ReadDataType.void_type:
      print("Converting Int[] to Void");
      break;
    case ReadDataType.character:
      print("Converting Int[] to Character");
      break;
    case ReadDataType.boolean:
      print("Converting Int[] to Boolean");
      break;
    case ReadDataType.integer:
      print("Converting Int[] to Integer");
      break;
    case ReadDataType.unsigned_integer:
      print("Converting Int[] to Unsigned Integer");
      break;
    case ReadDataType.floating_point:
      print("Converting Int[] to Floating Point");
      var buffer = Int8List(4).buffer;
      var bufferData = ByteData.view(buffer);
      for(int i = 0 ; i < 4; i++) {
        bufferData.setInt8(i, intList[intList.length-1-i]);
      }
      return bufferData.getFloat32(0).toString();
    case ReadDataType.double_floating_point:
      print("Converting Int[] to Double Floating Point");
      break;
    case ReadDataType.raw_binary_data:
      print("Converting Int[] to Raw Binary Data");
      break;
    case ReadDataType.string:
      print("Converting Int[] to String");
      StringBuffer stringBuffer = StringBuffer();
      intList.forEach((value) {
        stringBuffer.writeCharCode(value);
      });
      return stringBuffer.toString();
    case ReadDataType.float_3d_vector:
      print("Converting Int[] to Float 3D Vector");
      break;
    case ReadDataType.double_3d_vector:
      print("Converting Int[] to Double 3D Vector");
      break;
  }

  return null;
}
