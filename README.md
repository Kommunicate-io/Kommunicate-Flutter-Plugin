# Kommunicate Flutter plugin 
 Flutter wrapper using the native modules of Kommunicate Android and iOS SDKs. 

## Installation

1) Add the below dependency in your pubspec.yaml file:
```
dependencies:
  //other dependencies
  kommunicate_flutter_plugin: ^1.0.9
```

2) Install the package as below:
```
flutter pub get
```
3) Import the kommunicate_flutter_plugin in your .dart file to use the methods from Kommunicate:

```
import 'package:kommunicate_flutter_plugin/kommunicate_flutter_plugin.dart';
```

4) For iOS, navigate to YourApp/ios directory from terminal and run the below command:
```
pod install
```

>Note: Kommunicate iOS requires min ios platform version 10 and uses dynamic frameworks. Make sure you have the below settings at the top of your ios/Podfile:

```
 platform :ios, '10.0'
 use_frameworks!
```

## Get your Application Id
Sign up for [Kommunicate](https://dashboard.kommunicate.io) to get your [APP_ID](https://dashboard.kommunicate.io/settings/install). This APP_ID is used to create/launch conversations.


## Launch chat
Kommunicate provides buildConversation function to create and launch chat directly saving you the extra steps of authentication, creation, initialization and launch. You can customize the process by building the conversationObject according to your requirements.
To launch the chat you need to create a conversation object. This object is passed to the `buildConversation` function and based on the parameters of the object the chat is created/launched.

Below are some examples to launch chat in different scenarios:

### Launching chat for visitor:
If you would like to launch the chat directly without the visiting user entering any details, then use the method as below:

```dart
try {
     dynamic conversationObject = {
         'appId': '<APP_ID>' // The [APP_ID](https://dashboard.kommunicate.io/settings/install) obtained from kommunicate dashboard.
     };
      dynamic result = await KommunicateFlutterPlugin.buildConversation(conversationObject);
      print("Conversation builder success : " + result.toString());
    } on Exception catch (e) {
      print("Conversation builder error occurred : " + e.toString());
    }
```
### Launching chat for visitor with lead collection:
If you need the user to fill in details like phone number, emailId and name before starting the support chat then launch the chat with `withPreChat` flag as true. In this case you wouldn't need to pass the kmUser. A screen would open up for the user asking for details like emailId, phone number and name. Once the user fills the valid details (atleast emailId or phone number is required), the chat would be launched. Use the function as below:

```dart
try {
     dynamic conversationObject = {
         'appId': '<APP_ID>',// The [APP_ID](https://dashboard.kommunicate.io/settings/install) obtained from kommunicate dashboard.
         'withPreChat': true
      };
      dynamic result = await KommunicateFlutterPlugin.buildConversation(conversationObject);
      print("Conversation builder success : " + result.toString());
    } on Exception catch (e) {
      print("Conversation builder error occurred : " + e.toString());
    }
```

### Launching chat with existing user:
If you already have the user details then create a KMUser object using the details and launch the chat. Use the method as below to create KMUser with already existing details:

```dart
try {
     dynamic user = {
       'userId' : '<USER_ID>',   //Replace it with the userId of the logged in user
       'password' : '<PASSWORD>'  //Put password here if user has password, ignore otherwise
     };
     dynamic conversationObject = {
         'appId': '<APP_ID>',// The [APP_ID](https://dashboard.kommunicate.io/settings/install) obtained from kommunicate dashboard.
         'kmUser': jsonEncode(user)
      };
      dynamic result = await KommunicateFlutterPlugin.buildConversation(conversationObject);
      print("Conversation builder success : " + result.toString());
    } on Exception catch (e) {
      print("Conversation builder error occurred : " + e.toString());
    }
```
> Note: `jsonEncode` requires the dart package `dart:convert`. Make sure you have imported the package at the top of the dart file as `import 'dart:convert';`

If you have a different use-case and would like to customize the chat creation, user creation and chat launch, you can use more parameters in the conversationObject.

Below are all the parameters you can use to customize the conversation according to your requirements:

| Parameter        | Type           | Description  |
| ------------- |:-------------:| :-----|
| appId      | String      |   The [APP_ID](https://dashboard.kommunicate.io/settings/install) obtained from kommunicate dashboard |
| groupName      | String      |   Optional, you can pass a group name or ignore |
| kmUser | KMUser     |    Optional, Pass the details if you have the user details, ignore otherwise. The details you pass here are used **only the first time**, to login the user. These login details persists until the app is uninstalled or you call logout. |
| withPreChat | boolean      |   Optional, Pass true if you would like the user to fill the details before starting the chat. If you have user details then you can pass false or ignore. |
| isUnique | boolean      |   Optional,  Pass true if you would like to create only one conversation for every user. The next time user starts the chat the same conversation would open, false if you would like to create a new conversation everytime the user starts the chat. True is recommended for single chat|
| metadata      | dynamic      |   Optional. This metadata if set will be sent with all the messages sent from that device. Also this metadata will be set to the conversations created from that device.  |
| agentIds | List<String>      |    Optional, Pass the list of agents you want to add in this conversation. The agent ID is the email ID with which your agent is registered on Kommunicate. You may use this to add agents to the conversation while creating the conversation. Note that, conversation assignment will be done on the basis of the routing rules set in the [Conversation Rules section](https://dashboard.kommunicate.io/settings/conversation-rules). Adding agent ID here will only add the agents to the conversation and will not alter the routing rules.|
| botIds | List<String>      |    Optional, Pass the list of bots you want to add in this conversation. Go to [bots](https://dashboard.kommunicate.io/bot) -> Manage Bots -> Copy botID . Ignore if you haven't integrated any bots. You may use this to add any number of bots to the conversation while creating the conversation. Note that this has no effect on the conversation assignee, as the [Conversation Rules](https://dashboard.kommunicate.io/settings/conversation-rules) set forth in the Dashboard will prevail.|
| createOnly      | boolean      |   Optional. Pass true if you need to create the conversation and not launch it. In this case you will receive the clientChannelKey of the created conversation in the success callback function.|
  
## Send data to bot platform
You can set the data you want to send to the bot platform by calling the `updateChatContext` method as below:

```dart
  dynamic chatContext = {
          'key': 'value',
          'objKey': {
            'objKey1' : 'objValue1',
            'objKey2' : 'objValue2'
          }
        };

  KommunicateFlutterPlugin.updateChatContext(chatContext);
```

## Update logged in user's details
You can update some details of the logged in user like displayName, imageUrl, metadata etc. Use the `updateUserDetail` method as below (Remove the fields from the userDetails object below, which you don't want to update):

```dart
try {
  dynamic userDetails = {
          'displayName': '<New Name>',
          'imageLink': '<new-image-url>',
          'email': '<New-Email>',
          'contactNumber': '<New-Contact-Number>'
          'metadata': {
            'objKey1' : 'objValue1',
            'objKey2' : 'objValue2'
          }
        };

  KommunicateFlutterPlugin.updateUserDetail(userDetails);
  } on Exception catch (e) {
      print("Error occured while updating userDetails : " + e.toString());
 }
```

Note: `userId`is a unique identifier of a kmUser object. It cannot be updated.

## Logout
You can call the `logout` method to logout the user from kommunicate. Use the method as below:

```dart
  KommunicateFlutterPlugin.logout();
```
   
Here is the sample app which implements this SDK: https://github.com/Kommunicate-io/Kommunicate-Flutter-Plugin/tree/master/example
