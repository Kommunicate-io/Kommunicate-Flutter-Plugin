import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';

import 'AppConfig.dart';

String errorTextHolder = '';

class PreChatPage extends StatefulWidget {
  @override
  PreChatPageState createState() => PreChatPageState();
}

class PreChatPageState extends State<PreChatPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final GlobalKey<State> conversationLoader = new GlobalKey<State>();

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    emailController.dispose();
    errorTextHolder = '';
    super.dispose();
  }

  void buildConversationWithUser(context) {
    showLoadingDialog(context, conversationLoader);
    dynamic kmUser = {
      'userId': emailController.text,
      'displayName': nameController.text
    };

    dynamic conversationObject = {
      'appId': AppConfig.APP_ID,
      'isSingleConversation': true,
      'kmUser': jsonEncode(kmUser)
    };

    KommunicateFlutterPlugin.buildConversation(conversationObject)
        .then((result) {
      Navigator.of(conversationLoader.currentContext, rootNavigator: true)
          .pop();
      print("Conversation builder success : " + result.toString());
      Navigator.pop(context);
    }).catchError((error) {
      Navigator.of(conversationLoader.currentContext, rootNavigator: true)
          .pop();
      print("Conversation builder error occurred : " + error.toString());
    });
  }

  setErrorText(String errorText) {
    setState(() {
      errorTextHolder = errorText;
    });
  }

  void validateTextFields(context) {
    if (nameController.text.isEmpty) {
      setErrorText('Name cannot be empty!');
      return;
    }
    if (!AppConfig.isValidEmail(emailController.text)) {
      setErrorText('Invalid email Id');
      return;
    }

    setErrorText('');
    buildConversationWithUser(context);
  }

  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Opening conversation, Please Wait....",
                          style:
                              TextStyle(fontSize: 15, color: Colors.black),
                        )
                      ]),
                    )
                  ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.cancel),
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                    height: 100.0,
                    width: 100.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffe9e9e9),
                        image: new DecorationImage(
                            alignment: Alignment.center,
                            fit: BoxFit.scaleDown,
                            image: new AssetImage("assets/start_1.png")))),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'We just need a few details to help you get started',
                      style: TextStyle(fontSize: 16),
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff5c5aa7)),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      border: UnderlineInputBorder(),
                      labelStyle: TextStyle(color: Color(0xff5c5aa7)),
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff5c5aa7)),
                      ),
                      border: UnderlineInputBorder(),
                      labelStyle: TextStyle(color: Color(0xff5c5aa7)),
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: 'Name',
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                    alignment: Alignment.center,
                    child: Text('$errorTextHolder',
                        style: TextStyle(fontSize: 17, color: Colors.red))),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    height: 45,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Color(0xff5c5aa7),
                      child: Text('Start conversation'),
                      onPressed: () {
                        validateTextFields(context);
                      },
                    ))
              ],
            )));
  }
}
