import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class NotificationServer {
  BluetoothConnection? _connection;
  bool isConnected = false;

  Future<void> start(
      Function(String mittente, String testo) onMessageReceived) async {
    try {
      bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (isEnabled == false) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }

      List<BluetoothDevice> bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();

      if (bondedDevices.isNotEmpty) {
        BluetoothDevice device = bondedDevices.first;

        _connection = await BluetoothConnection.toAddress(device.address);
        isConnected = true;

        debugPrint('Connesso in Bluetooth a: ${device.name}');

        _connection!.input!.listen((Uint8List data) {
          String message = utf8.decode(data);

          if (message.contains('|')) {
            List<String> parts = message.split('|');
            if (parts.length >= 2) {
              onMessageReceived(parts[0].trim(), parts[1].trim());
            }
          }
        }).onDone(() {
          isConnected = false;
        });
      }
    } catch (e) {
      debugPrint("Errore connessione Bluetooth: $e");
      isConnected = false;
    }
  }

  void stop() {
    _connection?.dispose();
    _connection = null;
    isConnected = false;
  }
}
