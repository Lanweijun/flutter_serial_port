import 'dart:async';

import 'package:flutter/services.dart';

class SerialPort {
  static const MethodChannel _channel = const MethodChannel('serial_port');
  static const EventChannel _eventChannel = const EventChannel('serial_event');

  //示例插件获取系统版本
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List> findSerialPort() async {
    final List device = await _channel.invokeMethod('findSerialPort');
    return device;
  }

  //name 串口名   baud 波特率
  static Future<String> openSerialPort(String name, int baud) async {
    final String version = await _channel.invokeMethod(
        'openSerialPort', {'name': name, 'rate': baud, });
    return version;
  }

  static Future<String> closeSerialPort() async {
    final String version = await _channel.invokeMethod('closeSerialPort');
    return version;
  }

  //str  hex 字符串 需自己处理
  static Future<String> writeSerialPort(String str) async {
    final String version =
        await _channel.invokeMethod('writeSerialPort', {'str': str});
    return version;
  }

//  static  listenSerialPort(Function name,Map data){
//     _eventChannel.receiveBroadcastStream(data).listen(name);
//  }
  static  listenSerialPort(Function name){
    _eventChannel.receiveBroadcastStream().listen(name);
  }

}
