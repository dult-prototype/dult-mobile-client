import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Service constants
final nonOwnerServiceUuid = Guid('15190001-12F4-C226-88ED-2AC5579F2A85');
final nonOwnerControlPointUuid = Guid('8E0C0001-1D68-FB92-BF61-48377421680E');
const int GET_PRODUCT_DATA = 0x003;
const int GET_MANUFACTURER_NAME = 0x004;
const int GET_MODEL_NAME = 0x005;
const int GET_ACCESSORY_CATEGORY = 0x006;
const int GET_PROTOCOL_IMPLEMENTATION_VERSION = 0x007;
const int GET_ACCESSORY_CAPABILITIES = 0x008;
const int GET_NETWORK_ID = 0x009;
const int GET_FIRMWARE_VERSION = 0x00A;
const int GET_BATTERY_TYPE = 0x00B;
const int GET_BATTERY_LEVEL = 0x00C;
const int GET_SERIAL_NUMBER = 0x404;
const int GET_IDENTIFIER = 0x404;

const int SOUND_START = 0x300;
const int SOUND_STOP = 0x301;
const int SOUND_COMPLETED = 0x303;

const int GET_PRODUCT_DATA_RESPONSE = 0x803;
const int GET_MANUFACTURER_NAME_RESPONSE = 0x804;
const int GET_MODEL_NAME_RESPONSE = 0x805;
const int GET_ACCESSORY_CATEGORY_RESPONSE = 0x806;
const int GET_PROTOCOL_IMPLEMENTATION_VERSION_RESPONSE = 0x807;
const int GET_ACCESSORY_CAPABILITIES_RESPONSE = 0x808;
const int GET_NETWORK_ID_RESPONSE = 0x809;
const int GET_FIRMWARE_VERSION_RESPONSE = 0x80A;
const int GET_BATTERY_TYPE_RESPONSE = 0x80B;
const int GET_BATTERY_LEVEL_RESPONSE = 0x80C;
const int GET_SERIAL_NUMBER_RESPONSE = 0x405;
const int GET_IDENTIFIER_RESPONSE = 0x405;
const int COMMAND_RESPONSE = 0x302;

const String UNKNOWN = "Unknown";

const opcode_values_to_opcodes = {
  SOUND_START: 'Sound start',
  SOUND_STOP: 'Sound stop',
  SOUND_COMPLETED: 'Sound completed'
};

const batteryTypes = {
  "0": 'Powered',
  "1": 'Non Rechargeable Battery',
  "2": 'Rechargeable Battery'
};

const int SUCCESS = 0x0;

const String serverURL =
    "http://10.3.43.23:8080/serial-number-decrypt?serial-number=";

const response_status_mappings = {
  0x0: 'Success',
  0x0001: 'Invalid State',
  0x0002: 'Invalid Configuration',
  0x0003: 'Invalid length',
  0x0004: 'Invalid param',
  0xFFFF: 'Invalid command',
};

const accessoryCapabilities = [
  'Play Sound',
  'Motion detector UT',
  'Serial Number lookup by NFC',
  'Serial Number lookup by BLE'
];

const accessoryCategories = {
  1: 'Finder',
  129: 'Luggage',
  130: 'Backpack',
  // and so on..
};
