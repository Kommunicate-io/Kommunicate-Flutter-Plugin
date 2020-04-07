import 'dart:async';

import 'package:flutter/services.dart';

class KommunicateFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('kommunicate_flutter_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> buildConversation(dynamic conversationObject) async {
    return await _channel.invokeMethod('buildConversation', conversationObject);
  }

  static Future<dynamic> logout() async {
    return await _channel.invokeMethod('logout');
  }

  static Future<dynamic> updateChatContext(dynamic chatContext) async {
    return await _channel.invokeMethod('updateChatContext', chatContext);
  }

  static Future<dynamic> updateUserDetail(dynamic kmUser) async {
    return await _channel.invokeMethod('updateUserDetail', kmUser);
  }
}
