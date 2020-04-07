import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kommunicate_flutter_plugin/kommunicate_flutter_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// This is the type used by the popup menu below.
enum OptionMenu { logout }

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<dynamic> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await KommunicateFlutterPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<dynamic> openSupportChat() async {
    try {
      dynamic user = {'userId': 'reytum', 'password': 'reytum'};

      dynamic convObject = {'appId': '22823b4a764f9944ad7913ddb3e43cae1'};
      dynamic result =
          await KommunicateFlutterPlugin.buildConversation(convObject);

      dynamic chatContext = {
        'key': 'value',
        'objKey': {'objKey1': 'objValue1', 'objKey2': 'objValue2'}
      };

      try {
        dynamic kmUser = {
          'metadata': {
            'Platform': 'Flutter 1',
            'OS': 'Android',
            'Version': '10.3'
          }
        };
        KommunicateFlutterPlugin.updateUserDetail(kmUser);
      } on Exception catch (e) {
        print("Error while updating user details : " + e.toString());
      }

      KommunicateFlutterPlugin.updateChatContext(chatContext);
      print("Conversation builder success : " + result.toString());
    } on Exception catch (e) {
      print("Conversation builder error occurred : " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Kommunicate Flutter Plugin example app'),
            actions: <Widget>[
              PopupMenuButton<OptionMenu>(
                onSelected: (OptionMenu result) {
                  KommunicateFlutterPlugin.logout();
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<OptionMenu>>[
                      const PopupMenuItem<OptionMenu>(
                        value: OptionMenu.logout,
                        child: Text('Logout'),
                      ),
                    ],
              )
            ],
          ),
          body: Center(
            child: Text('Running on: $_platformVersion\n'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              openSupportChat();
            },
            label: Text('Support'),
            icon: Icon(Icons.chat),
            backgroundColor: Colors.pink,
          )),
    );
  }
}
