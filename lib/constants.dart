import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Service constants
final nonOwnerServiceUuid = Guid('00000090-710e-4a5b-8d75-3e5b444bc3cf');
final nonOwnerControlPointUuid = Guid('00000090-0100-0000-0000-000000000000');
const int GET_PRODUCT_DATA = 0x306;
const int GET_MANUFACTURER_NAME = 0x307;
const int GET_MODEL_NAME = 0x308;
const int GET_ACCESSORY_CATEGORY = 0x309;
const int GET_ACCESSORY_CAPABILITIES = 0x30A;
const int GET_SERIAL_NUMBER = 0x404;

const int SOUND_START = 0x300;
const int SOUND_STOP = 0x301;
const int SOUND_COMPLETED = 0x303;

const int GET_PRODUCT_DATA_RESPONSE = 0x311;
const int GET_MANUFACTURER_NAME_RESPONSE = 0x312;
const int GET_MODEL_NAME_RESPONSE = 0x313;
const int GET_ACCESSORY_CATEGORY_RESPONSE = 0x314;
const int GET_ACCESSORY_CAPABILITIES_RESPONSE = 0x315;
const int GET_SERIAL_NUMBER_RESPONSE = 0x405;
const int COMMAND_RESPONSE = 0x302;

const String UNKNOWN = "Unknown";

const opcode_values_to_opcodes = {
  SOUND_START: 'Sound start',
  SOUND_STOP: 'Sound stop',
  SOUND_COMPLETED: 'Sound completed'
};

const int SUCCESS = 0x0;

const String serverURL = "http://10.3.43.23:8080/serial-number-decrypt?serial-number=";

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