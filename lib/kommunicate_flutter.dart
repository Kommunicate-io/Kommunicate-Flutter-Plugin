import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class KommunicateFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('kommunicate_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> buildConversation(dynamic conversationObject) async {
    return await _channel.invokeMethod('buildConversation', jsonEncode(conversationObject));
  }

  static Future<dynamic> logout() async {
    return await _channel.invokeMethod('logout');
  }

  static Future<dynamic> updateChatContext(dynamic chatContext) async {
    return await _channel.invokeMethod('updateChatContext', jsonEncode(chatContext));
  }

  static Future<dynamic> updateUserDetail(dynamic kmUser) async {
    return await _channel.invokeMethod('updateUserDetail', jsonEncode(kmUser));
  }

  static Future<dynamic> login(dynamic kmUser) async {
    return await _channel.invokeMethod('login', jsonEncode(kmUser));
  }

  static Future<dynamic> loginAsVisitor(String appId) async {
    return await _channel.invokeMethod('loginAsVisitor', appId);
  }

  static Future<dynamic> openConversations() async {
    return await _channel.invokeMethod('openConversations');
  }

  static Future<dynamic> openParticularConversation(
      String clientConversationId) async {
    return await _channel.invokeMethod(
        'openParticularConversation', clientConversationId);
  }

  static Future<dynamic> unreadCount() async {
    return await _channel.invokeMethod('unreadCount');
  }

  static Future<dynamic> isLoggedIn() async {
    return await _channel.invokeMethod('isLoggedIn');
  }

  static Future<dynamic> fetchUserDetails(String userid) async {
    return await _channel.invokeMethod('fetchUserDetails', userid);
  }

  static Future<dynamic> updateTeamId(dynamic conversationObject) async {
    return await _channel.invokeMethod('updateTeamId', conversationObject);
  }
  
  static Future<dynamic> hideChatListOnNotification() async {
    return await _channel.invokeMethod('hideChatListOnNotification');
  }
  static Future<dynamic> updateDefaultSetting(dynamic defaultSetting) async {
    return await _channel.invokeMethod('updateDefaultSetting', jsonEncode(defaultSetting));
  }
  static Future<dynamic> createConversationInfo(dynamic defaultSetting) async {
    return await _channel.invokeMethod('createConversationInfo', jsonEncode(defaultSetting));
  }
  static Future<dynamic> closeConversationScreen() async {
    return await _channel.invokeMethod('closeConversationScreen');
  }
}
