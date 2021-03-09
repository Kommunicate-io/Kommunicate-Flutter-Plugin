import 'package:kommunicate_flutter_plugin_example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    try {} catch (e) {}
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff5c5aa7),
            title: const Text('Welcome to Kommunicate!'),
          ),
          body: HomePageWidget()),
    );
  }
}

// ignore: must_be_immutable
class HomePageWidget extends StatelessWidget {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool isGroupInProgress = false;

  String getPlatformName() {
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      return "iOS";
    } else {
      return "NOP";
    }
  }

  String getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  int getTimeStamp() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    KommunicateFlutterPlugin.openConversations();
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Open conversations",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    KommunicateFlutterPlugin.openParticularConversation(
                        '46286348');
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Open Particular Conversation",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    KommunicateFlutterPlugin.updateChatContext({
                      'key': 'value',
                      'objKey': {'objKey1': 'objValue1', 'objKey2': 'objValue2'}
                    }).then((value) {
                      print('Chat context updated' + value.toString());
                    }).catchError((error) {
                      print(
                          'Error in updating chat context' + error.toString());
                    });
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Update chat context",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    KommunicateFlutterPlugin.updateUserDetail({
                      'displayName':
                          "FUser-" + getCurrentTime() + "-" + getPlatformName(),
                      'metadata': {
                        'plugin': "Kommunicate Flutter",
                        'platform': getPlatformName(),
                        'userUpdateTime': getCurrentTime()
                      }
                    }).then((value) {
                      print('User details updated : ' + value.toString());
                    }).catchError((error) {
                      print('Error in updating user details : ' +
                          error.toString());
                    });
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Update user",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    KommunicateFlutterPlugin.logout().then((value) {
                      print("Logout successful : " + value);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyApp()));
                    }).catchError((error, stack) =>
                        print("Logout failed : " + error.toString()));
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Logout",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ))
          ],
        ),
      ),
    );
  }
}
