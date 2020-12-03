## 1.1.1
  Changed the package name from "kommunicate_flutter_plugin" to "kommunicate_flutter"

  Migration to version 1.1.1 from 1.1.0

  * Change the plugin name in pubspec.yaml from "kommunicate_flutter_plugin" to "kommunicate_flutter"
  * Change the imports from:
      import 'package:kommunicate_flutter_plugin/kommunicate_flutter_plugin.dart';
       to:
      import 'package:kommunicate_flutter/kommunicate_flutter.dart';
      
## 1.1.0
* Added new functions for Authentication:
  - isLoggedIn(): To check weather the user is logged in or not
  - login(kmUser): login the user to Kommunicate
  - loginAsVisitor(): login the user without pre existing details. The user will be logged in as a Visitor

* Added new Conversation methods:
  - openConversations(): Open the conversation List for the logged in user
  - openParticularConversation(String clientConversationId): Open the conversation for the passed clientConversationId

## 0.0.1

* TODO: Describe initial release.
