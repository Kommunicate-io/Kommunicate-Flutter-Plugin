import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'dart:io' show Platform;
import 'main.dart';

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
    } else if (kIsWeb) {
      return "Web";
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

  void fetchUserDetails(String userid) {
    try {
      KommunicateFlutterPlugin.fetchUserDetails(userid)
          .then((value) => print("User details fetched: " + value));
    } on Exception catch (e) {
      print("Fetching user details error : " + e.toString());
    }
  }

  String valueText = '';
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter User ID'),
            content: TextField(
              onChanged: (value) {
                valueText = value;
                print(value);
              },
              decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('CANCEL'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  fetchUserDetails(valueText);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        });
  }

String coversationIDValue = '';
  Future<void> _displayConversationIDInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Conversation ID'),
            content: TextField(
              onChanged: (value) {
                coversationIDValue = value;
                print(value);
              },
              decoration: InputDecoration(hintText: "Enter Conversation ID"),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('CANCEL'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  KommunicateFlutterPlugin.openParticularConversation(coversationIDValue);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        });
  }

  String messageText = '';
  Future<void> _displayMessageInputDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Message and Conversation ID'),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.2, // Set the height to 30% of the screen height
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    coversationIDValue = value;
                    print(value);
                  },
                  decoration: InputDecoration(hintText: "Enter Conversation ID"),
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    messageText = value;
                    print(value);
                  },
                  decoration: InputDecoration(hintText: "Enter Message"),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              KommunicateFlutterPlugin.sendMessage({
                "channelID": "$coversationIDValue",
                "message": "$messageText"
              });
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
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
                    // KommunicateFlutterPlugin.openParticularConversation(
                    //     '46286348');
                    _displayConversationIDInputDialog(context);
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
                    KommunicateFlutterPlugin.updateTeamId({
                      //'conversationId': 70780495,
                      'clientConversationId': '69360869',
                      'teamId': '63641656'
                    }).then((value) {
                      print('team context updated' + value.toString());
                    }).catchError((error) {
                      print(
                          'Error in updating team context' + error.toString());
                    });
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Update team",
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
                      _displayTextInputDialog(context);
                    },
                    minWidth: 400,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    child: Text("Fetch User Details",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))),
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
                )),
    ];

    if (kIsWeb) {
      widgets.removeRange(widgets.length - 9, widgets.length - 1);
      widgets.insert(
        widgets.length - 1, // Insert before the logout button
        new Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xff5c5aa7),
          child: new MaterialButton(
            onPressed: () {
              KommunicateFlutterPlugin.buildConversation({})
              .then((result) {
                print("Conversation builder success : " + result.toString());
              }).catchError((error) {
                print("Conversation builder error occurred : " + error.toString());
              });
            },
            minWidth: 400,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            child: Text(
              "Build Conversation",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
      widgets.insert(
        widgets.length - 1,
        SizedBox(height: 10),
      );
      widgets.insert(
        widgets.length - 1, // Insert before the logout button
        new Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xff5c5aa7),
          child: new MaterialButton(
            onPressed: () {
              _displayMessageInputDialog(context);
            },
            minWidth: 400,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            child: Text(
              "Send Message",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
      widgets.insert(
        widgets.length - 1,
        SizedBox(height: 10),
      );
      widgets.insert(
        widgets.length - 1, // Insert before the logout button
        new Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xff5c5aa7),
          child: new MaterialButton(
            onPressed: () {
              KommunicateFlutterPlugin.isChatWidgetVisible(false);
            },
            minWidth: 400,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            child: Text(
              "Hide Chat Widget",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
      widgets.insert(
        widgets.length - 1,
        SizedBox(height: 10),
      );
      widgets.insert(
        widgets.length - 1, // Insert before the logout button
        new Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xff5c5aa7),
          child: new MaterialButton(
            onPressed: () {
              KommunicateFlutterPlugin.isChatWidgetVisible(true);
            },
            minWidth: 400,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            child: Text(
              "Show Widget",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
      widgets.insert(
        widgets.length - 1,
        SizedBox(height: 10),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }
}
