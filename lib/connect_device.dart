import 'package:dult_client/constants.dart' as constants;
import 'package:dult_client/helper.dart' as helper;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectDevice extends StatefulWidget {
  final BluetoothDevice device;

  ConnectDevice(this.device);

  @override
  _ConnectDeviceState createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  bool isConnected = false;
  bool isConnecting = false;
  bool supportsDULT = true;
  bool isSoundPlaying = false;

  BluetoothCharacteristic? targetCharacteristic;
  String productData = '';
  String manufacturerName = '';
  String modelName = '';
  String accessoryCategory = '';
  List<String> accessoryCapabilities = [];
  String serialNumber = '';
  String protocolImplementationVersion = '';
  String batteryType = '';
  String batteryLevel = '';
  String firmwareVersion = '';
  String networkId = '';

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  void connectToDevice() async {
    try {
      setState(() {
        supportsDULT = true;
        isConnecting = true;
      });
      // listen for disconnection
      widget.device.connectionState
          .listen((BluetoothConnectionState state) async {
        setState(() {
          isConnected = (state == BluetoothConnectionState.connected);
        });
      });
      await widget.device.connect();

      setState(() {
        isConnected = true;
      });

      List<BluetoothService> services = await widget.device.discoverServices();

      BluetoothService targetService = services.firstWhere(
        (service) =>
            service.uuid.toString() == constants.nonOwnerServiceUuid.toString(),
        orElse: () => throw Exception('Service not found'),
      );

      targetCharacteristic = targetService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid.toString() ==
            constants.nonOwnerControlPointUuid.toString(),
        orElse: () => throw Exception('Characteristic not found'),
      );

      targetCharacteristic?.onValueReceived.listen(indicationHandler);

      // Subscribe to indications
      await targetCharacteristic?.setNotifyValue(true, timeout: 30);

      performAction(constants.GET_PRODUCT_DATA);
      performAction(constants.GET_MANUFACTURER_NAME);
      performAction(constants.GET_MODEL_NAME);
      performAction(constants.GET_ACCESSORY_CATEGORY);
      performAction(constants.GET_ACCESSORY_CAPABILITIES);
      performAction(constants.GET_FIRMWARE_VERSION);
      performAction(constants.GET_NETWORK_ID);
      performAction(constants.GET_BATTERY_LEVEL);
      performAction(constants.GET_BATTERY_TYPE);
      performAction(constants.GET_PROTOCOL_IMPLEMENTATION_VERSION);
    } catch (e) {
      setState(() {
        supportsDULT = false;
        isConnected = false;
      });
      print('Error connecting to the device: $e');
    }
    setState(() {
      isConnecting = false;
    });
  }

  void indicationHandler(List<int> value) {
    int opcode = helper.bytesToInt(value.sublist(0, 2));
    if (opcode == constants.GET_PRODUCT_DATA_RESPONSE) {
      setState(() {
        productData = helper.convertBytesToString(value.sublist(2));
      });
    } else if (opcode == constants.GET_MODEL_NAME_RESPONSE) {
      setState(() {
        modelName = helper.convertBytesToString(value.sublist(2));
      });
    } else if (opcode == constants.GET_MANUFACTURER_NAME_RESPONSE) {
      setState(() {
        manufacturerName = helper.convertBytesToString(value.sublist(2));
      });
    } else if (opcode == constants.GET_ACCESSORY_CATEGORY_RESPONSE) {
      setState(() {
        accessoryCategory = helper.getAccessoryCategory(
                helper.convertBytesToString(value.sublist(2))) ??
            constants.UNKNOWN;
      });
    } else if (opcode == constants.GET_ACCESSORY_CAPABILITIES_RESPONSE) {
      setState(() {
        accessoryCapabilities = helper.getAccessoryCapabilities(
            helper.convertBytesToString(value.sublist(2)));
      });
    } else if (opcode == constants.GET_PROTOCOL_IMPLEMENTATION_VERSION_RESPONSE) {
      setState(() {
        protocolImplementationVersion = helper.convertBytesToString(value.sublist(2));
      });
    } else if (opcode == constants.GET_BATTERY_TYPE_RESPONSE) {
      setState(() {
        batteryType = helper.getBatteryType(helper.convertBytesToString(value.sublist(2))) ?? constants.UNKNOWN;
      });
    } else if (opcode == constants.GET_BATTERY_LEVEL_RESPONSE) {
      setState(() {
        batteryLevel = helper.convertBytesToString(value.sublist(2));
      });
    } else if (opcode == constants.GET_FIRMWARE_VERSION_RESPONSE) {
      setState(() {
        firmwareVersion = helper.convertBytesToString(value.sublist(2));
      });
    } else if (opcode == constants.GET_NETWORK_ID_RESPONSE) {
      setState(() {
        networkId = helper.convertBytesToString(value.sublist(2));
      });
    } else if (opcode == constants.COMMAND_RESPONSE) {
      int commandOpcode = helper.bytesToInt(value.sublist(2, 4));
      int responseStatus = helper.bytesToInt(value.sublist(4));
      String message =
          '${constants.opcode_values_to_opcodes[commandOpcode]} : ${constants.response_status_mappings[responseStatus]}';
      if (responseStatus == constants.SUCCESS) {
        if (commandOpcode == constants.SOUND_START && !isSoundPlaying) {
          _showSoundPlayingDialog(context);
          setState(() {
            isSoundPlaying = true;
          });
        } else if ((commandOpcode == constants.SOUND_STOP ||
                commandOpcode == constants.SOUND_COMPLETED) &&
            isSoundPlaying) {
          Navigator.of(context).pop();
          setState(() {
            isSoundPlaying = false;
          });
        }
      } else {
        showNotification(context, message, Colors.red);
      }
    } else if (opcode == constants.GET_SERIAL_NUMBER_RESPONSE) {
      String message =
          'Serial Number: ${helper.convertBytesToString(value.sublist(2))}';
      showNotification(context, message, Colors.green);
      // _launchUrl('${constants.serverURL}helper.convertBytesToString(value.sublist(2))');
    } else {
      String message = 'Unknown Response';
      showNotification(context, message, Colors.red);
    }
  }

  void performAction(int opcode) async {
    try {
      await targetCharacteristic
          ?.write([((opcode >> 8) & 0xFF), (opcode & 0xFF)]);
    } catch (e) {
      print('Error writing opcode: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void showNotification(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: SizedBox(
        height: 30.0,
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildConnectingStatus() {
    return Visibility(
      visible: isConnecting,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
          color: Colors.green,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              'Connecting',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedStatus() {
    return Visibility(
      visible: !isConnecting && !isConnected,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              'Disconnected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoesNotSupportDULT() {
    return Visibility(
      visible: !supportsDULT,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              'Device does not support DULT protocol',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(helper.getDeviceName(widget.device.platformName)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Reload the widget by reconnecting to the device
                connectToDevice();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (isConnecting) _buildConnectingStatus(),
              if (!isConnecting && !isConnected) _buildDisconnectedStatus(),
              if (!supportsDULT) _buildDoesNotSupportDULT(),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Device Information',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          _buildDeviceDetails(),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      _buildDeviceFields(),
                      const SizedBox(height: 20.0),
                      _buildButtons(),
                    ],
                  )),
            ],
          ),
        ));
  }

  Future<void> _showSoundPlayingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sound Playing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.volume_up,
                size: 50.0,
                color: Colors.blue,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Close the dialog when the 'Done' button is pressed
                  performAction(constants.SOUND_STOP);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Name: ${helper.getDeviceName(widget.device.platformName)}',
          style: const TextStyle(fontSize: 18.0),
        ),
        Text(
          'Bluetooth Address: ${widget.device.remoteId.toString()}',
          style: const TextStyle(fontSize: 18.0),
        ),
      ],
    );
  }

  Widget _buildDeviceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField('Product Data', productData),
        _buildField('Manufacturer Name', manufacturerName),
        _buildField('Model Name', modelName),
        _buildField('Accessory Category', accessoryCategory),
        _buildField('Accessory Capabilities', accessoryCapabilities.join(', ')),
        // _buildField('Serial Number', serialNumber),
        _buildField('Battery Type', batteryType),
        _buildField('Battery Level', batteryLevel),
        _buildField('Protocol Implementation Version', protocolImplementationVersion),
        _buildField('Network Id', networkId),
        _buildField('Firmware Version', firmwareVersion),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        Text(
          value.isEmpty ? 'No data' : value,
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            performAction(constants.SOUND_START);
          },
          icon: const Icon(Icons.volume_up),
          label: const Text('Play Sound'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            performAction(constants.GET_SERIAL_NUMBER);
          },
          icon: const Icon(Icons.key),
          label: const Text('Serial Number'),
        ),
      ],
    );
  }
}
