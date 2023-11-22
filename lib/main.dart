import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'connect_device.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.none, color: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScanResult> devices = [];
  bool bluetoothOn = false;

  @override
  void initState() {
    super.initState();
    checkBluetoothStatus();
    startScanning();
  }

  @override
  void dispose() {
    stopScanning();
  }

  void checkBluetoothStatus() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      setState(() {
        bluetoothOn = state == BluetoothAdapterState.on;
        if (bluetoothOn) {
          startScanning();
        }
      });
    });
  }

  void startScanning() {
    FlutterBluePlus.scanResults.listen((results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last;
        setState(() {
          devices = results;
        });
      }
    });
    if(bluetoothOn) {
      FlutterBluePlus.startScan();
    }
  }

  void stopScanning() {
    FlutterBluePlus.stopScan();
  }

  String getDeviceName(String deviceName) {
    return deviceName.isNotEmpty ? deviceName : 'Unknown device';
  }

  Widget _buildBluetoothOffMessage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detecting Unwanted Trackers'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 60.0,
              color: Colors.red,
            ),
            SizedBox(height: 16.0),
            Text(
              'Please turn on Bluetooth',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              stopScanning();
              startScanning();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return Card(
                  // elevation: 2.0,
                  child: ListTile(
                    title: Text(
                      getDeviceName(devices[index].device.platformName),
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 20.0),
                    ),
                    subtitle: Text(devices[index].device.remoteId.toString()),
                    // trailing: Icon(Icons.bluetooth),
                    onTap: () {
                      // Handle device selection if needed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ConnectDevice(devices[index].device),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return bluetoothOn ? _buildScanner() : _buildBluetoothOffMessage();
  }
}
