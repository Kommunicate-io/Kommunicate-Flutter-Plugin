## 1.6.6
- Added support for custom attachment endpoint - iOS

  
## 1.6.5
- Added support for group creation source in SDK- Android
- Added support for Multilingual bot - Android
- Added support for custom attachment endpoint
- Fixed Event data not getting passed to List Template 
- Fixed events build issue - iOS

  
## 1.6.4
- Added support for custom toolbar subtitle - iOS
- Added support to add top static first message
- Fixed form data submission payload 

## 1.6.3
- Added support for custom toolbar subtitle
- Changed Message View layout to Top to Bottom
- Add support to add top static first message

## 1.6.2
- Fixed resetting conversation info view issue

## 1.6.0
- Added support for Multiple Select Button AsMultipleButton
- Added support to show conversation info view below topbar

## 1.5.6
- Updated Readme.MD and description
- Fixed build issue


## 1.5.5
- Added support to send platform flag for analytics
- Added logout option on conversation screen - Android
- Handle Notifications from FCM directly - Android
- Added support for AES256 encryption and decryption - Android
- Added fix for API <= 19. Current min SDK version is still 16. All bugs have been fixed for lower SDK versions.
- Added Edit Message Text box Customization - "messageEditTextBackgroundColor" - Android
- Added support to set Custom bot name through Chat Context
- Added Support for Android API 33 
- Threads optimized and multiple crash fixed - Android
- Added Support for App Extension - iOS
- Fixed add contact permission to info.list issue when app is submitted on App Store - iOS
- Added Button to create new conversation on conversation list screen - iOS 


## 1.5.1

- Added Support for Android API 33 
- Added multiple events to Event Listners
- Added Customisation for Start New Conversation Button background color | Android SDK
- Added fix for Android API <= 19. Current min SDK version is still 16. All bugs have been fixed for lower SDK versions. | Android SDK
- Added Edit Message Text box Customization - "messageEditTextBackgroundColor" | Android SDK
- Added Card Template Customisation | iOS SDK
- Form template Issue in small screen devices | iOS SDK
- Added support to set Custom bot name through Chat Context | Android SDK
- Moved Android permissions to App level Manifest. You must add permissions in AndroidManifest.xml

## 1.5.0

- Upgraded Android version to 2.4.3
- Add color customization for notification icon
- Added support to set Notification tone
- Added icon to link Rich Messages
- Crash fix

 ## 1.4.9

- Upgraded Android version to 2.4.2
- Upgraded iOS version to 6.7.1
- fix for double click on openParticularConversation
- fix for bot loading message continuously
- fix for Rich Message button text crop
- fix for bot name hiding in push notification click

 
## 1.4.8

- added hideChatListOnNotification method 
- updated iOS SDK to 6.7.0

## 1.4.7

- Display Name accepting spaces now
- Upgraded Android SDK version to 2.4.1

## 1.4.6

- postBackToBotPlatform fix
- upgrade Android version to 2.4.0
  
## 1.4.5

- iOS build fix

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
