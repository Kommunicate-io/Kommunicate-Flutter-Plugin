## 1.8.7
### iOS
- Fixed Build Conversation issue
## 1.8.6
### iOS
- Fixed Form Rich Message Rendering issue
- Added support for showing assingment message
- Fixed Reply meta issue on Quick Reply Button
### Android
- Added support for dialogflow fulfilment form
- Fixed agent app not showing notifications after automatic assignment
- Added support for chatwidget disabled flag
- Fixed autosuggestion
- Fixed channel messages showing in SDK
## 1.8.5
### iOS
- Zendesk (Zopim) integration optimisations
- Fixed Suggested Reply Rich Message is not getting rendered while scrolling on conversation screen
- Time Label Font Change
- Added support of form data using dialog flow fulfillment
- Fixed minor crashes
## 1.8.4
### Android
- Added customisation for multiple attachment selection
- Fixed documents showing incorrect filename for non-english names
- Fixed autosuggestion rich message
## 1.8.3
-Fixed link preview showing for deep link
-Added the caption Screen for Attachment.
-Fixed HTML Message view in Conversation List Screen.
-Fixed Location blue bar coming in message bubble
-Fixed New Form UI Cutting from Bottom.
-Updated the User Update Api
-Fixed message status icon colour customisation(Android)
## 1.8.2
- Added a conversationResolved event listener on iOS
## 1.8.1
- Fixed typing indicator for welcome message (ANDROID)
- Fixed "no conversations" showing sometimes for the first time when conversation is created (ANDROID)
- Fix the random order of item in dropdown list (ANDROID)
- Provided customisation To change mainDivider line colour (ANDROID & iOS)
- Changed UI for typing indicator (iOS)
## 1.8.0
- Added Support of Video Rich Message(iOS).
- Fixed the attachment upload issue(iOS).
- Fixed Conversation Missmatch issue(iOS).
## 1.7.9
- Bug fixes
## 1.7.8
- Added a method to get channel key if you pass channelID or clientChannelKey if you pass channel key
- Fixed issue related to unread Count
## 1.7.7
- Fixed send message method in android.
## 1.7.6
- Fixed unread Count in android Side.
- Added support of prefill checkboxes on Form Template.
- Default configuration added for disabling the form submit button using 'disableFormPostSubmit'.
## 1.7.5
- Fixed hidePostCta
## 1.7.4
- Expose the Language change code. `KommunicateFlutterPlugin.updateUserLanguage("fr")`
- Expose Method to update the chat bar text fill. `KommunicateFlutterPlugin.updatePrefilledText(String)`
- Expose the Send Message code. `KommunicateFlutterPlugin.sendMessage()`
- Added Support of `fetchUserDetails` - iOS.
- Reduce time taken for conversation creation
## 1.7.3
- Fixed the crash when "applozic-settigs.json" is not present in the app
- Removed Forced TypeCasting 
## 1.7.2
- Upgraded minimum deployment target to iOS-13
- Fixed crashes on android side
## 1.7.1
- Added platform flag.

## 1.7.0
- Added support for API Suggestions
- Fixed visibility of startNewConversation button
- Fixed crashes

## 1.6.9
- Fix for assignee status not updating

## 1.6.8
- Expose Method to hide Assignee online/offline status - `KommunicateFlutterPlugin.hideAssigneeStatus(boolean)`

## 1.6.7
- Fixed Upload attachment issue to custom cloud service - iOS

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
