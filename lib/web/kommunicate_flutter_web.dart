// Inside web/kommunicate_flutter_web.dart

import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';

class KommunicateFlutterPluginWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'kommunicate_flutter',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = KommunicateFlutterPluginWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'login':
        return login(call.arguments);
      case 'logout': 
        return logout();
      case 'loginAsVisitor':
        return loginAsVisitor(call.arguments);
      case 'openConversations': 
        return openConversations();
      case 'sendMessage':
        return sendMessage(call.arguments);
      case 'openParticularConversation': 
        return openParticularConversation(call.arguments);
      case 'isLoggedIn':
        return isLoggedIn();
      case 'buildConversation': 
        return buildConversation(call.arguments);
      case 'updateChatContext':
        return updateChatContext(call.arguments);
      case 'updateUserDetail': 
        return updateUserDetail(call.arguments); 
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'kommunicate_flutter for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<dynamic> login(dynamic kmUser) async {
    Map<String, dynamic> user =  jsonDecode(kmUser);
    String appId = user["appId"];
    String userId = user['userId'];
    if (!appId.isEmpty && !userId.isEmpty) {
      String jsCode = '''
              (function(d, m){
                var kommunicateSettings = {
                  "appId": "$appId",
                  "automaticChatOpenOnNavigation": true,
                  "popupWidget": true,
                  "userId": "$userId"
                };
                var s = document.createElement("script");
                s.type = "text/javascript";
                s.async = true;
                s.src = "https://widget.kommunicate.io/v2/kommunicate.app";
                var h = document.getElementsByTagName("head")[0];
                h.appendChild(s);
                window.kommunicate = m;
                m._globals = kommunicateSettings;
              })(document, window.kommunicate || {});
            ''';
      await js.context.callMethod('eval', [jsCode]);
    }
  }

  Future<dynamic> logout() async {
    await js.context.callMethod('eval', ['Kommunicate.logout()']);
  }

 Future<dynamic> loginAsVisitor(String appId) async {
      String jsCode = '''
              (function(d, m){
                var kommunicateSettings = {
                  "appId": "$appId",
                  "automaticChatOpenOnNavigation": true,
                  "popupWidget": true
                };
                var s = document.createElement("script");
                s.type = "text/javascript";
                s.async = true;
                s.src = "https://widget.kommunicate.io/v2/kommunicate.app";
                var h = document.getElementsByTagName("head")[0];
                h.appendChild(s);
                window.kommunicate = m;
                m._globals = kommunicateSettings;
              })(document, window.kommunicate || {});
            ''';
      await js.context.callMethod('eval', [jsCode]);
  }

  Future<dynamic> openConversations() async {
    await js.context.callMethod('eval', ['Kommunicate.openConversationList()']);
  }

  Future<dynamic> sendMessage(dynamic messageData) async {
     Map<String, dynamic> messageObjc =  jsonDecode(messageData);
     String channelID = messageObjc["channelID"];
     String message = messageObjc["message"];

    await js.context.callMethod('eval', ['Kommunicate.sendMessage({"goupId": "$channelID", "message": "$message"})']);
  }

  Future<dynamic> openParticularConversation(String clientConversationId) async {
    await js.context.callMethod('eval', ['Kommunicate.openConversation("$clientConversationId")']);
  }

  Future<dynamic> isLoggedIn() async {
    // await js.context.callMethod('eval', ['Kommunciate']);
  }

  Future<dynamic> updateChatContext(dynamic chatContext) async {
    
  }

  Future<dynamic> updateUserDetail(dynamic kmUser) async {

  }

  Future<dynamic> buildConversation(dynamic conversationObject) async {
    Map<String, dynamic> conversationData =  jsonDecode(conversationObject);
    Map<String, dynamic> conversationDetail = {};

    if (conversationData["messageMetadata"]) {
      conversationDetail["conversationMetadata"] = conversationData["messageMetadata"];
    }
    if (conversationData["agentIds"]) {
      conversationDetail["agentIds"] = conversationData["agentIds"];
      if (!conversationDetail["skipRouting"]) {
        conversationDetail["skipRouting"] = "true";
      }
    }
    if (conversationData["botIds"]) {
      conversationDetail["botIds"] = conversationData["botIds"];
      if (!conversationDetail["skipRouting"]) {
        conversationDetail["skipRouting"] = "true";
      }
    }
    if (conversationData["conversationAssignee"]) {
      conversationDetail["assignee"] = conversationData["conversationAssignee"];
      if (!conversationDetail["skipRouting"]) {
        conversationDetail["skipRouting"] = "true";
      }
    }
    if (conversationData["clientConversationId"]) {
      conversationDetail["clientGroupId"] = conversationData["clientConversationId"];
    }
    if (conversationData["conversationTitle"]) {
      conversationDetail["defaultGroupName"] = conversationData["conversationTitle"];
    }
    print("converastionON : $conversationDetail");
  }
  
}
