import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:kommunicate_flutter_plugin/kommunicate_flutter_plugin.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
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
          title: const Text('Kommunicate sample app'),
        ),
        body: LoginPage(),
      ),
    );
  }
}

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final String APP_ID = '<Your-App-ID>';
  TextEditingController userId = new TextEditingController();
  TextEditingController password = new TextEditingController();

  void loginUser(context) {
    dynamic user = {
      'userId': userId.text,
      'password': password.text,
      'appId': APP_ID
    };

    KommunicateFlutterPlugin.login(user).then((result) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
      print("Login successful : " + result.toString());
    }).catchError((error) {
      print("Login failed : " + error.toString());
    });
  }

  void loginAsVisitor(context) {
    KommunicateFlutterPlugin.loginAsVisitor(APP_ID).then((result) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
      print("Login as visitor successful : " + result.toString());
    }).catchError((error) {
      print("Login as visitor failed : " + error.toString());
    });
  }

  void buildConversation() {
    dynamic conversationObject = {'appId': APP_ID};

    KommunicateFlutterPlugin.buildConversation(conversationObject)
        .then((result) {
      print("Conversation builder success : " + result.toString());
    }).catchError((error) {
      print("Conversation builder error occurred : " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      KommunicateFlutterPlugin.isLoggedIn().then((value) {
        print("Logged in : " + value.toString());
        if (value) {
          print("Logged in after check");
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      });
    } on Exception catch (e) {
      print("isLogged in error : " + e.toString());
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 155.0,
              child: Image.asset(
                "assets/ic_launcher_without_shape.png",
                fit: BoxFit.contain,
              ),
            ),
            new TextField(
              controller: userId,
              decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "UserId *",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0))),
            ),
            SizedBox(height: 10),
            new TextField(
              controller: password,
              obscureText: true,
              decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "Password *",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0))),
            ),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    loginUser(context);
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                          .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    loginAsVisitor(context);
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Login as Visitor",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                          .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff5c5aa7),
                child: new MaterialButton(
                  onPressed: () {
                    buildConversation();
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Use conversation builder",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                          .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ))
          ],
        ),
      ),
    );
  }
}
