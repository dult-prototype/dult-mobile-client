import 'dart:math';

import 'package:dult_client/constants.dart' as constants;


String getDeviceName(String deviceName) {
  return deviceName.isNotEmpty ? deviceName : 'Unknown device';
}

String convertBytesToString(List<int> byteList) {
  return String.fromCharCodes(byteList);
}

int bytesToInt(List<int> bytes){
  int opcode = 0;
  for(int i = 0; i < bytes.length; i++){
    opcode <<= 8;
    opcode += bytes[i];
  }
  return opcode;
}

String? getAccessoryCategory(String accessoryCategory){
  int intValue = int.parse(accessoryCategory);
  if(constants.accessoryCategories.containsKey(intValue)) {
    return constants.accessoryCategories[intValue];
  }
  return constants.UNKNOWN;
}

List<String> getAccessoryCapabilities(String accessoryCapability){
  String binaryString = int.parse(accessoryCapability).toRadixString(2);
  int leadingZeroes = max(0, constants.accessoryCapabilities.length - binaryString.length);
  binaryString = '0' * leadingZeroes + binaryString;
  List<String> result = [];
  for(int i = 0; i < binaryString.length; i++){
    if(binaryString[i] == '1'){
      result.add(constants.accessoryCapabilities[i]);
    }
  }
  return result;
}

String? getBatteryType(String batteryType){
  if(constants.batteryTypes.containsKey(batteryType)){
    return constants.batteryTypes[batteryType];
  }
  return constants.UNKNOWN;
}