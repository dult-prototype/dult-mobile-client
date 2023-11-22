import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothAdapterState? state;

  const BluetoothOffScreen({
    super.key,
    this.state,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("Bluetooth Status"),
    ),
    backgroundColor: Theme.of(context).colorScheme.background,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.bluetooth_disabled,
            size: 200.0,
            color: Colors.white54,
          ),
          Text(
            'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
            style: Theme.of(context).primaryTextTheme.titleMedium,
            // .copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}