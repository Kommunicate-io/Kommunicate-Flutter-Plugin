## 1.4.4

- Upgrade Android version to 2.3.8
- Upgrade iOS version to 6.6.0
- Added support to send attachment to S3

## 1.4.3+1

- Documentation update

## 1.4.3

- Bug resolve and improvement

## 1.4.2

- Android 12 notification issue fixe
- Design upgrade in Android

## 1.4.0

- Added support for Android 12
- Update Android SDK version to 2.3.0

## 1.3.2

- Update iOS SDK version to 6.3.1

## 1.3.1

- Fix for PreChatViewController delegate methods

## 1.3.0

- Update iOS SDK version to 6.3.0
- Added support for Xcode 13

## 1.2.2

- Update iOS SDK version to 6.2.1

## 1.2.1

- Update iOS SDK version to 6.2.0

## 1.2.0

- Update iOS SDK version to 6.1.1

## 1.1.9

- Added support for setting conversationTitle in iOS
- Added support for setting conversationInfo in iOS

## 1.1.8

- Update Android SDK version to 2.1.8
- Update iOS SDK version to 6.1.0

## 1.1.7

### Android

- Added support for auto suggesstion type rich message
- Added support to update conversationAssignee and conversationMetadata
- Added away messages changes in real time
- Added support to sync messages on conversation screen launch. Push notification is not a mandatory step now.
- Some crash fixes and optimisations

## 1.1.6

### Android

- Support for dropdown list in form rich message
- Change in format for date and time type rich messages
- Setting to restrict message typing with bots
- Move proguard rules to SDK
- Fix away message update in realtime

## 1.1.5

- Team Id support
- Customization options for prechat form in iOS

## 1.1.4

- Added method to get total unread messages count

## 1.1.3

- Added settings to change toolbar, statusbar and rich message theme color in android
- Added option to set teamId in android
- Added an option to show/hide different message menu options in iOS.
- Now, chat bar's attachment color config will be applied to the bottom part of the chat bar as well in iOS
- Fixed issue with localization crash in android
- Added a check for whitespace and newline characters in the user ID in iOS

## 1.1.2

- Fixed issue where kommunicate plugin podspec file was not being found by the plugin
- Fixed issue where plugin methods were not accessible on channel kommunicate_flutter
- Updated iOS SDK version to 5.9.0

## 1.1.1

Changed the package name from "kommunicate_flutter_plugin" to "kommunicate_flutter"

Migration to version 1.1.1 from 1.1.0

- Change the plugin name in pubspec.yaml from "kommunicate_flutter_plugin" to "kommunicate_flutter"
- Change the imports from:
  import 'package:kommunicate_flutter_plugin/kommunicate_flutter_plugin.dart';
  to:
  import 'package:kommunicate_flutter/kommunicate_flutter.dart';

## 1.1.0

- Added new functions for Authentication:

  - isLoggedIn(): To check weather the user is logged in or not
  - login(kmUser): login the user to Kommunicate
  - loginAsVisitor(): login the user without pre existing details. The user will be logged in as a Visitor

- Added new Conversation methods:
  - openConversations(): Open the conversation List for the logged in user
  - openParticularConversation(String clientConversationId): Open the conversation for the passed clientConversationId

## 0.0.1

- TODO: Describe initial release.
