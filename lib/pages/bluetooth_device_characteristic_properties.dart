import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceCharacteristicProperties extends StatefulWidget {
  final CharacteristicProperties properties;

  DeviceCharacteristicProperties({Key key, @required this.properties})
      : super(key: key);

  @override
  _DeviceCharacteristicPropertiesState createState() => _DeviceCharacteristicPropertiesState();
}

class _DeviceCharacteristicPropertiesState extends State<DeviceCharacteristicProperties> {

  @override
  void initState() {
    super.initState();
  }

  ListTile _buildTile(String title, String subtitle) {
    return ListTile(
        onTap: null,
        onLongPress: null,
        contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
        title: Text(
          title,
          style: TextStyle(fontSize: 18),
        ),
        isThreeLine: true,
        subtitle: Text(
            "$subtitle"));
  }

  Widget _buildBluetoothCharacteristicTile({int index}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            _buildTile("Broadcast", widget.properties.broadcast.toString()),
            _buildTile("Read", widget.properties.read.toString()),
            _buildTile("Write Without Response", widget.properties.writeWithoutResponse.toString()),
            _buildTile("Write", widget.properties.write.toString()),
            _buildTile("Notify", widget.properties.notify.toString()),
            _buildTile("Indicate", widget.properties.indicate.toString()),
            _buildTile("Authenticated Signed Writes", widget.properties.authenticatedSignedWrites.toString()),
            _buildTile("Extended Properties", widget.properties.extendedProperties.toString()),
            _buildTile("Notify Encryption Required", widget.properties.notifyEncryptionRequired.toString()),
            _buildTile("Indicate Encryption Required", widget.properties.indicateEncryptionRequired.toString()),

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
      title: Text("Properties"),
      centerTitle: true,
    );
  }

  ListView _buildList() {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildBluetoothCharacteristicTile(index: index),
              index != 10
                  ? _doubleDivider(indent: 8, endIndent: 8)
                  : null
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildExtendedAppbar(), body: _buildList());
  }

  @override
  void dispose() {
    super.dispose();
  }
}
