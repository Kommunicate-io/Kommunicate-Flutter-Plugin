import Flutter
import UIKit
import Kommunicate
import KommunicateCore_iOS_SDK
import KommunicateChatUI_iOS_SDK

public class SwiftKommunicateFlutterPlugin: NSObject, FlutterPlugin, KMPreChatFormViewControllerDelegate, ALKCustomEventCallback {
    
    var methodChannel: FlutterMethodChannel;
    var appId : String? = nil;
    var agentIds: [String]? = [];
    var botIds: [String]? = [];
    var createOnly: Bool = false
    var isSingleConversation: Bool = true;
    var callback: FlutterResult?
    var conversationAssignee: String? = nil;
    var clientConversationId: String? = nil;
    var conversationTitle: String? = nil;
    var conversationInfo: [AnyHashable: Any]? = nil;
    var teamId: String? = nil;
    static let KM_CONVERSATION_METADATA: String = "conversationMetadata";
    static let CLIENT_CONVERSATION_ID: String = "clientConversationId";
    static let CONVERSATION_ID: String = "conversationId";
    
    
     init(channel: FlutterMethodChannel) {
         self.methodChannel = channel
         super.init()
         self.addListener()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "kommunicate_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftKommunicateFlutterPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func addListener() {
        Kommunicate.subscribeCustomEvents(events: [CustomEvent.messageReceive, CustomEvent.messageSend,CustomEvent.faqClick, CustomEvent.newConversation, CustomEvent.submitRatingClick, CustomEvent.restartConversationClick, CustomEvent.richMessageClick, CustomEvent.conversationBackPress, CustomEvent.conversationListBackPress, CustomEvent.conversationInfoClick ], callback: self)
    }
    func removeListener() {
        Kommunicate.unsubcribeCustomEvents()
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.callback = result
        
        if(call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if(call.method == "isLoggedIn") {
            result(Kommunicate.isLoggedIn)
        } else if(call.method == "login") {
            guard let jsonString = call.arguments as? String, var userDict = jsonString.convertToDictionary() else {
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse user JSON")
                return
            }

            guard let appId = userDict["appId"] as? String, !appId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self.sendErrorResultWithCallback(result: result, message: "Invalid or missing appId")
                return
            }
            Kommunicate.setup(applicationId: appId)
            userDict.removeValue(forKey: "appId")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDict, options: .prettyPrinted)
                let jsonString = String(bytes: jsonData, encoding: .utf8)
                let kmUser = KMUser(jsonString: jsonString)
                kmUser?.applicationId = userDict["appId"] as? String
                kmUser?.platform = NSNumber(value: PLATFORM_FLUTTER.rawValue)
                
                Kommunicate.registerUser(kmUser!, completion: {
                    response, error in
                    guard error == nil else {
                        self.sendErrorResultWithCallback(result: result, message: error!.localizedDescription)
                        return
                    }
                    self.sendSuccessResultWithCallback(result: result, object: (response?.dictionary())!)
                })
            } catch {
                self.sendErrorResultWithCallback(result: result, message: error.localizedDescription)
            }
        } else if(call.method == "loginAsVisitor") {
            guard let appId = call.arguments as? String, !appId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self.sendErrorResultWithCallback(result: result, message: "Invalid or missing appId")
                return
            }
            
            Kommunicate.setup(applicationId: appId)
            let kmUser = Kommunicate.createVisitorUser()
            kmUser.applicationId = appId
            kmUser.platform = NSNumber(value: PLATFORM_FLUTTER.rawValue)
            
            Kommunicate.registerUserAsVistor (kmUser, completion: {
                response, error in
                guard error == nil else {
                    self.sendErrorResultWithCallback(result: result, message: error!.localizedDescription)
                    return
                }
                self.sendSuccessResultWithCallback(result: result, object: (response?.dictionary())!)
            })
        } else if(call.method == "openConversations") {
            DispatchQueue.main.async{
                if let top = UIApplication.topViewController(){
                    Kommunicate.showConversations(from: top)
                    self.sendSuccessResultWithCallback(result: result, message: "Successfully launched conversation list screen")
                } else {
                    self.sendErrorResultWithCallback(result: result, message: "Failed to launch conversation list screen")
                }
            }
        } else if(call.method == "openParticularConversation") {
            guard let conversationId = call.arguments as? String else {
                self.sendErrorResultWithCallback(result: result, message: "Invalid or empty conversationId")
                return
            }
            let alChannelService = ALChannelService()
            var conversationID = String()
            if Int(conversationId) != nil {
                alChannelService.getChannelInformation(NSNumber(value: Int(conversationId)!), orClientChannelKey: nil) { (channel) in
                    if channel != nil && channel?.clientChannelKey != nil {
                        conversationID = channel!.clientChannelKey
                        self.openParticularConversation(conversationID, true, result)

                    }
                }
            } else {
                self.openParticularConversation(conversationId, true, result)
            }
        } else if(call.method == "updatePrefilledText") {
            guard let prefilledText = call.arguments as? String else {
                self.sendErrorResultWithCallback(result: result, message: "Invalid PreFilled Text")
                return
            }
            Kommunicate.updatePrefilledText(prefilledText)
        } else if(call.method == "sendMessage") {
            guard let jsonString = call.arguments as? String, var jsonObj = jsonString.convertToDictionary(), let conversationID = jsonObj["channelID"] as? String, let message = jsonObj["message"] as? String else {
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse send Message Object")
                return
            }
            let conversationId = conversationID
            let sendMessage = KMMessageBuilder()
                .withConversationId(conversationId)
                .withText(message)
                .build()

            Kommunicate.sendMessage(message: sendMessage) { error in
                guard error == nil else {
                    self.sendErrorResultWithCallback(result: result, message: "Failed to send message: \(String(describing: error?.localizedDescription))")
                    return
                }
            }
        } else if(call.method == "getConversarionIdOrKey") {
            guard let jsonString = call.arguments as? String, var jsonObj = jsonString.convertToDictionary() else {
                self.sendErrorResultWithCallback(result: result, message: "Empty Object no data")
                return
            }
            let alChannelService = ALChannelService()
            if let channelID = jsonObj["channelID"] {
                guard let channelID = channelID as? Int else{
                    self.sendErrorResultWithCallback(result: result, message: "Channel ID is not Integer")
                    return
                }
                alChannelService.getChannelInformation(NSNumber(integerLiteral: channelID), orClientChannelKey: nil) { channel in
                    guard let channel = channel else {
                        self.sendErrorResultWithCallback(result: result, message: "Conversation Not Found \(channel)")
                        return
                    }
                    self.sendSuccessResult(message: channel.clientChannelKey)
                }
            } else if let clientChannelKey = jsonObj["clientChannelKey"] {
                guard let clientChannelKey = clientChannelKey as? String else {
                    self.sendErrorResultWithCallback(result: result, message: "Client Channel Key is not String")
                    return
                }
                alChannelService.getChannelInformation(nil, orClientChannelKey: clientChannelKey) { channel in
                    guard let channel = channel , let conversationID = channel.key else {
                        self.sendErrorResultWithCallback(result: result, message: "Conversation Not Found \(channel)")
                        return
                    }
                    self.sendSuccessResult(message: "\(conversationID)")
                }
            } else {
                self.sendErrorResultWithCallback(result: result, message: "Object doesn't contain 'clientChannelKey' or 'channelID'")
            }
        }else if(call.method == "updateTeamId") {
            
                       guard let jsonObj = call.arguments as? Dictionary<String, Any>, let teamId = jsonObj["teamId"] as? String else {
                            self.sendErrorResultWithCallback(result: result, message: "Invalid or empty teamId")
                            return
                        }
            guard jsonObj[SwiftKommunicateFlutterPlugin.CLIENT_CONVERSATION_ID] != nil || jsonObj[SwiftKommunicateFlutterPlugin.CONVERSATION_ID] != nil else {
                self.sendErrorResultWithCallback(result: result, message: "Invalid or empty clientConversationId or conversationId")
                
                return
            }
            if(Kommunicate.isLoggedIn) {
                        var clientConversationId: String? = nil
                            if(jsonObj[SwiftKommunicateFlutterPlugin.CLIENT_CONVERSATION_ID]) != nil {
                           
                            clientConversationId = jsonObj[SwiftKommunicateFlutterPlugin.CLIENT_CONVERSATION_ID] as? String
                            }
                            else {
                                guard let conversationId = jsonObj[SwiftKommunicateFlutterPlugin.CONVERSATION_ID] as? Int else {
                                    return
                                }
                                let alChannelService = ALChannelService()
                                    alChannelService.getChannelInformation(NSNumber(value: conversationId), orClientChannelKey: nil) { (channel) in
                                        if channel != nil && channel?.clientChannelKey != nil {
                                            clientConversationId = channel!.clientChannelKey
                                        }
                                    }
                            }
                             let conversation = KMConversationBuilder().withClientConversationId(clientConversationId).build() 
                            
                                Kommunicate.updateTeamId(conversation: conversation, teamId: teamId){ response in
                                switch response {
                                case .success(let conversationId):
                                    self.sendSuccessResultWithCallback(result: result, message: "Successfully updated Team")
                                    break
                                case .failure(let error):
                                    
                                        self.sendErrorResultWithCallback(result: result, message: "Failed to update Team")
                                    break
                                }
                                }
                       
                        } else {
                            sendErrorResultWithCallback(result: result, message: "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the chatContext")
                        }
        } else if(call.method == "fetchUserDetails") {
            guard let userId = call.arguments as? String else {
                return
            }
            ALUserService().fetchAndupdateUserDetails([userId]) {
                userDetails, error in
                guard let userDetails = userDetails, let userDetail = userDetails[0] as? ALUserDetail else {
                    self.sendErrorResultWithCallback(result: result, message: error?.localizedDescription ?? "Error while parsing the user details.")
                    return
                }
                self.sendSuccessResultWithCallback(result: result, object: userDetail.toDictionary())
            }
        } else if(call.method == "buildConversation") {
            self.isSingleConversation = true
            self.createOnly = false;
            self.agentIds = [];
            self.botIds = [];
            self.conversationAssignee = nil
            self.clientConversationId = nil
            self.teamId = nil
            self.conversationInfo = nil
            self.conversationTitle = nil
            
            do {
                guard let jsonString = call.arguments as? String, var jsonObj = jsonString.convertToDictionary() else {
                    self.sendErrorResultWithCallback(result: result, message: "Unable to parse Conversation Object")
                    return
                }
                
                var withPrechat : Bool = false
                var kmUser : KMUser? = nil
                
                if jsonObj["appId"] != nil {
                    appId = jsonObj["appId"] as? String
                }
                
                if jsonObj["withPreChat"] != nil, let data = jsonObj["withPreChat"] as? Bool {
                    withPrechat = data
                }
                
                if jsonObj["isSingleConversation"] != nil, let data = jsonObj["isSingleConversation"] as? Bool {
                    self.isSingleConversation = data
                }
                
                if jsonObj["createOnly"] != nil, let data = jsonObj["createOnly"] as? Bool {
                    self.createOnly = data
                }
                
                if jsonObj["conversationAssignee"] != nil {
                    self.conversationAssignee = jsonObj["conversationAssignee"] as? String
                }
                
                if jsonObj["clientConversationId"] != nil {
                    self.clientConversationId = jsonObj["clientConversationId"] as? String
                }
                
                if jsonObj["teamId"] != nil {
                    self.teamId = jsonObj["teamId"] as? String
                }
                
                if jsonObj["conversationTitle"] != nil {
                    self.conversationTitle = jsonObj["conversationTitle"] as? String
                }
                
                if jsonObj["conversationInfo"] != nil {
                    conversationInfo = [SwiftKommunicateFlutterPlugin.KM_CONVERSATION_METADATA: jsonObj["conversationInfo"] as Any]
                }
                
                if let messageMetadataStr = jsonObj["messageMetadata"] as? [String : Any] {
                        Kommunicate.defaultConfiguration.messageMetadata = messageMetadataStr
                }
                
                let agentIds = jsonObj["agentIds"] as? [String]
                let botIds = jsonObj["botIds"] as? [String]
                
                self.agentIds = agentIds
                self.botIds = botIds
                
                if Kommunicate.isLoggedIn{
                    self.handleCreateConversation()
                }else{
                    if jsonObj["appId"] != nil {
                        guard let appId =  jsonObj["appId"] as? String else {
                            self.sendErrorResult(message: "Application Id is not a String")
                            return
                        }
                        Kommunicate.setup(applicationId: appId)
                    }
                    
                    if !withPrechat {
                        if jsonObj["kmUser"] != nil {
                            guard let kmUserString = jsonObj["kmUser"] as? String else { 
                                self.sendErrorResult(message: "kmUser is not enocoded correctly.")
                                return
                            }
                            var jsonSt = kmUserString
                            jsonSt = jsonSt.replacingOccurrences(of: "\\\"", with: "\"")
                            jsonSt = "\(jsonSt)"
                            kmUser = KMUser(jsonString: jsonSt)
                            kmUser?.applicationId = appId
                        } else {
                            kmUser = KMUser.init()
                            kmUser?.userId = Kommunicate.randomId()
                            kmUser?.applicationId = appId
                        }
                        guard let kmUser = kmUser else { 
                            self.sendErrorResult(message: "kmUser is nil")    
                            return 
                        }
                        Kommunicate.registerUser(kmUser, completion:{
                            response, error in
                            guard error == nil else{
                                self.sendErrorResult(message: error!.localizedDescription)
                                return
                            }
                            self.handleCreateConversation()
                        })
                    } else {
                        DispatchQueue.main.async {
                            let controller = KMPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
                            controller.delegate = self
                            UIApplication.topViewController()?.present(controller, animated: false, completion: nil)
                        }
                    }
                }
            } catch _ as NSError {
                
            }
        } else if(call.method == "logout") {
            Kommunicate.logoutUser { (logoutResult) in
                switch logoutResult {
                case .success(_):
                    result(String("Logout success"))
                case .failure( _):
                    self.sendErrorResultWithCallback(result: result, message: "Error in logout")
                }
            }
        } else if(call.method == "updateChatContext") {
            guard let chatContextString = call.arguments as? String, var chatContext = chatContextString.convertToDictionary() else {
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse Chat context Object")
                return
            }
            do {
                if(Kommunicate.isLoggedIn) {
                    try Kommunicate.defaultConfiguration.updateChatContext(with: chatContext)
                    sendSuccessResultWithCallback(result: result, message: "Success")
                } else {
                    sendErrorResultWithCallback(result: result, message: "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the chatContext")
                }
            } catch  {
                print(error)
                sendErrorResultWithCallback(result: result, message: error.localizedDescription)
            }
        } else if(call.method == "updateUserDetail") {
            guard let kmUserString = call.arguments as? String, var kmUser = kmUserString.convertToDictionary() else {
                sendErrorResultWithCallback(result: result, message: "Invalid kmUser object")
                return
            }
            if(Kommunicate.isLoggedIn) {
                self.updateUser(displayName: kmUser["displayName"] as? String, imageLink: kmUser["imageLink"] as? String, status: kmUser["status"] as? String, metadata: kmUser["metadata"] as? [String: Any], phoneNumber: kmUser["contactNumber"] as? String, email: kmUser["email"] as? String, result: result)
            } else {
                sendErrorResultWithCallback(result: result, message: "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the user details")
            }
        } else if(call.method == "unreadCount") {
            result(ALUserService().getTotalUnreadCount()?.stringValue)
        } else if(call.method == "hideChatListOnNotification") {
            KMPushNotificationHandler.hideChatListOnNotification = true
            result(String("Chat list hidden on Notification"))
        }  else if(call.method == "updateDefaultSetting") {
            guard let jsonString = call.arguments as? String, let settingDict = jsonString.convertToDictionary() else {
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse JSON")
                return
            }
            Kommunicate.defaultConfiguration.clearDefaultConversationSettings()
            if(settingDict["defaultAssignee"] != nil) {
                Kommunicate.defaultConfiguration.defaultAssignee = settingDict["defaultAssignee"] as? String
            }
            if(settingDict["teamId"] != nil) {
                Kommunicate.defaultConfiguration.defaultTeamId = settingDict["teamId"] as? String
            }
            if let skipRouting = settingDict["skipRouting"] as? Bool {
                Kommunicate.defaultConfiguration.defaultSkipRouting = skipRouting
            }
            if let agentIds = settingDict["defaultAgentIds"] as? [String], !agentIds.isEmpty {
                Kommunicate.defaultConfiguration.defaultAgentIds = agentIds
            }
            if let botIds = settingDict["defaultBotIds"] as? [String], !botIds.isEmpty {
                Kommunicate.defaultConfiguration.defaultBotIds = botIds
            }
            result(String("Default Settings changed"))
        } else if(call.method == "createConversationInfo") {
            guard let jsonString = call.arguments as? String, let settingDict = jsonString.convertToDictionary() else {
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse JSON")
                return
            }
                if let show = settingDict["show"] as? Bool,
                    show == false {
                    Kommunicate.defaultConfiguration.conversationInfoModel = nil
                    return
                }
            var bg = UIColor(5, green: 163, blue: 191) ?? UIColor.blue
            var trailing = UIImage(named: "next") ?? UIImage()
            var leading = UIImage(named: "file") ?? UIImage()
            var font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
            var infoContent: String = ""
            var contentColor = UIColor.white
                if(settingDict["backgroundColor"] != nil) {
                    bg = UIColor(hexString: settingDict["backgroundColor"] as? String, alpha: 1)
            }
                if(settingDict["trailingIcon"] != nil) {
                 trailing = UIImage(named: settingDict["trailingIcon"] as? String ?? "next") ?? UIImage()
            }
                if(settingDict["leadingIcon"] != nil) {
                    leading = UIImage(named: settingDict["leadingIcon"] as? String ?? "files") ?? UIImage()
            }
            if(settingDict["infoContent"] != nil) {
                infoContent = settingDict["infoContent"] as? String ?? ""
            }
             if(settingDict["contentTextColor"] != nil) {
                 contentColor = UIColor(hexString: settingDict["contentTextColor"] as? String, alpha: 1) ?? UIColor.white
             }
            
            let model = KMConversationInfoViewModel(infoContent: infoContent, leadingImage: leading, trailingImage:trailing , backgroundColor: bg, contentColor: contentColor, contentFont:font)
            Kommunicate.defaultConfiguration.conversationInfoModel = model
        }
        else if(call.method == "closeConversationScreen") {
            DispatchQueue.main.async {
                UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
            }
        } else if(call.method == "createCustomToolbar") {
            guard let jsonString = call.arguments as? String, let toolbarDict = jsonString.convertToDictionary() else {
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse JSON")
                return
            }
                if let show = toolbarDict["show"] as? Bool,
                    show == false {
                    Kommunicate.kmConversationViewConfiguration.toolbarSubtitleText = ""
                    Kommunicate.kmConversationViewConfiguration.toolbarSubtitleRating = -1.0
                    return
                }
            if(toolbarDict["experienceText"] != nil) {
                Kommunicate.kmConversationViewConfiguration.toolbarSubtitleText = toolbarDict["experienceText"] as? String ?? ""
            }
            if(toolbarDict["rating"] != nil) {
                Kommunicate.kmConversationViewConfiguration.toolbarSubtitleRating = toolbarDict["rating"] as? Float ?? -1.0
            }

        } else if(call.method == "hideAssigneeStatus") {
            guard let hide = call.arguments as? Bool else {
                self.sendErrorResultWithCallback(result: result, message: "Invalid or missing argument")
                return
            }
            Kommunicate.hideAssigneeStatus(hide)
        } else if(call.method == "updateUserLanguage")  {
            guard let languageCode = call.arguments as? String else {
                print("language passed is not a string")
                return
            }
            do {
                try Kommunicate.defaultConfiguration.updateUserLanguage(tag: languageCode)
            } catch {
                print("error while passing the language code.")
            }
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func openParticularConversation(_ conversationId: String,_ skipConversationList: Bool, _ callback: @escaping FlutterResult) -> Void {
        DispatchQueue.main.async{
            if let top = UIApplication.topViewController(){
                Kommunicate.showConversationWith(groupId: conversationId, from: top, completionHandler: ({ (shown) in
                    if(shown){
                        callback(conversationId)
                    } else {
                        self.sendErrorResultWithCallback(result: callback, message: "Failed to launch conversation with conversationId : " + conversationId)
                    }
                }))
            } else {
                self.sendErrorResultWithCallback(result: callback, message: "Failed to launch conversation with conversationId : " + conversationId)
            }
        }
    }
    
    public func closeButtonTapped() {
        UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
    }
    
    public func userSubmittedResponse(name: String, email: String, phoneNumber: String, password: String) {
        UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
        
        let kmUser = KMUser.init()
        guard let applicationKey = appId else {
            return
        }
        
        kmUser.applicationId = applicationKey
        
        if(!email.isEmpty){
            kmUser.userId = email
            kmUser.email = email
        }else if(!phoneNumber.isEmpty){
            kmUser.contactNumber = phoneNumber
        }
        
        kmUser.contactNumber = phoneNumber
        kmUser.displayName = name
        Kommunicate.setup(applicationId: applicationKey)
        Kommunicate.registerUser(kmUser, completion:{
            response, error in
            guard error == nil else{
                self.sendErrorResult(message: "Unable to login")
                return
            }
            self.handleCreateConversation()
        })
    }
    
    func handleCreateConversation() {
        let builder = KMConversationBuilder();
        
        if let agentIds = self.agentIds, !agentIds.isEmpty {
            builder.withAgentIds(agentIds)
        }
        
        if let botIds = self.botIds, !botIds.isEmpty {
            builder.withBotIds(botIds)
        }
        
        builder.useLastConversation(self.isSingleConversation)
        
        if let assignee = self.conversationAssignee {
            builder.withConversationAssignee(assignee)
        }
        
        if let clientConversationId = self.clientConversationId {
            builder.withClientConversationId(clientConversationId)
        }
        
        if let teamId = self.teamId {
            builder.withTeamId(teamId)
        }
        
        if let conversationTitle = self.conversationTitle {
            builder.withConversationTitle(conversationTitle)
        }
        
        if let conversationInfo = self.conversationInfo {
            builder.withMetaData(conversationInfo)
        }
        
        Kommunicate.createConversation(conversation: builder.build(),
                                       completion: { response in
                                        switch response {
                                        case .success(let conversationId):
                                            if self.createOnly {
                                                self.sendSuccessResult(message: conversationId)
                                            } else {
                                                self.openParticularConversation(conversationId, true, self.callback!)
                                            }
                                            self.sendSuccessResult(message: conversationId)
                                            
                                        case .failure(let error):
                                            self.sendErrorResult(message: error.localizedDescription)
                                        }
                                       })
    }
    
    func sendErrorResultWithCallback(result: FlutterResult, message: String) {
        result(FlutterError(code: "Error", message: message, details: nil))
    }
    
    func sendSuccessResultWithCallback(result: FlutterResult, message: String) {
        result(message)
    }
    
    func sendErrorResult(message: String) {
        guard  let result = self.callback  else{
            return
        }
        sendErrorResultWithCallback(result: result, message: message)
    }
    
    func sendSuccessResult(message: String) {
        guard let result = self.callback else{
            return
        }
        sendSuccessResultWithCallback(result: result, message: message)
    }
    
    func sendSuccessResultWithCallback(result: FlutterResult, object: [AnyHashable : Any]) {
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            let jsonString = String(bytes: jsonData, encoding: .utf8)
            result(jsonString)
        } catch {
            sendSuccessResultWithCallback(result: result, message: "Success")
        }
    }
    
    func updateUser (displayName: String?, imageLink : String?, status: String?, metadata: [String: Any]?,phoneNumber: String?,email : String?, result: FlutterResult!) {
        
        let theUrlString = "\(ALUserDefaultsHandler.getBASEURL() as String)/rest/ws/user/update"
        
        let dictionary = NSMutableDictionary()
        if (displayName != nil) {
            dictionary["displayName"] = displayName
        }
        if imageLink != nil {
            dictionary["imageLink"] = imageLink
        }
        if status != nil {
            dictionary["statusMessage"] = status
        }
        if (metadata != nil) {
            dictionary["metadata"] = metadata
        }
        if phoneNumber != nil {
            dictionary["phoneNumber"] = phoneNumber
        }
        if email != nil {
            dictionary["email"] = email
        }
        var postdata: Data? = nil
        do {
            postdata = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        } catch {
            self.sendErrorResultWithCallback(result: result, message: error.localizedDescription)
            return
        }
        var theParamString: String? = nil
        if let postdata = postdata {
            theParamString = String(data: postdata, encoding: .utf8)
        }
        let theRequest = ALRequestHandler.createPOSTRequest(withUrlString: theUrlString, paramString: theParamString)
        ALResponseHandler().authenticateAndProcessRequest(theRequest,andTag: "UPDATE_DISPLAY_NAME_AND_PROFILE_IMAGE", withCompletionHandler: {
            theJson, theError in
            guard theError == nil else {
                self.sendErrorResultWithCallback(result: result, message: theError!.localizedDescription)
                return
            }
            guard let apiResponse = ALAPIResponse(jsonString: theJson as? String),apiResponse.status != "error"  else {
                let reponseError = NSError(domain: "Kommunicate", code: 1, userInfo: [NSLocalizedDescriptionKey : "ERROR IN JSON STATUS WHILE UPDATING USER STATUS"])
                self.sendErrorResultWithCallback(result: result, message: reponseError.localizedDescription)
                return
            }
            //Update the local contact
            let alContact = ALContactDBService().loadContact(byKey: "userId", value: ALUserDefaultsHandler.getUserId())
            if alContact == nil {
                self.sendErrorResultWithCallback(result: result, message: "User not found")
                return
            }
            if email != nil {
                alContact?.email = email
            }
            if phoneNumber != nil {
                alContact?.contactNumber = phoneNumber
            }
            if displayName != nil {
                alContact?.displayName = displayName
            }
            if imageLink != nil {
                alContact?.contactImageUrl = imageLink
            }
            if metadata != nil {
                alContact?.metadata = metadata as? NSMutableDictionary
            }
            ALContactDBService().updateContact(inDatabase: alContact)
            self.sendSuccessResultWithCallback(result: result, message: "Success")
        })
    }
    
    public func messageSent(message: ALMessage) {
        guard let messageDict = message.dictionary() as? NSDictionary else { return }
        methodChannel.invokeMethod("onMessageSent", arguments: ["data":convertDictToString(dict: messageDict)])
    }
    
    public func messageReceived(message: ALMessage) {
        guard let messageDict = message.dictionary() as? NSDictionary else { return }
        methodChannel.invokeMethod("onMessageReceived", arguments: ["data":convertDictToString(dict: messageDict)])

    }
    
    public func conversationRestarted(conversationId: String) {
        methodChannel.invokeMethod("onConversationRestarted", arguments: ["data":conversationId])
    }

    public func onBackButtonClick(isConversationOpened: Bool) {
        methodChannel.invokeMethod("onBackButtonClicked", arguments: ["data":isConversationOpened])
    }

    public func faqClicked(url: String) {
        methodChannel.invokeMethod("onFaqClick", arguments: ["data":url])
    }

    public func conversationCreated(conversationId: String) {
        methodChannel.invokeMethod("onStartNewConversation", arguments: ["data":conversationId])
    }

    public func ratingSubmitted(conversationId: String, rating: Int, comment: String) {
        let ratingDict: NSDictionary = ["conversationId": conversationId, "rating":rating, "feedback": comment]
        methodChannel.invokeMethod("onSubmitRatingClick", arguments: ["data": convertDictToString(dict: ratingDict)])
    }

    public func richMessageClicked(conversationId: String, action: Any, type: String) {
        let jsonEncoder = JSONEncoder()
        var actionString: String = ""
        if action is ListTemplate.Element, let actionElement = action as? ListTemplate.Element,
           let jsonData = try? jsonEncoder.encode(actionElement)
        {
            actionString = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
        } else if let actionDict = action as? [String: Any] {
            actionString = convertDictToString(dict: actionDict as NSDictionary)
        } else {
            print("Could not parse Rich Message action object")
        }
        let richMessageDict: [String:Any] = ["conversationId": conversationId,"action": actionString, "actionType": type]
        methodChannel.invokeMethod("onRichMessageButtonClick", arguments: ["data": convertDictToString(dict: richMessageDict as NSDictionary)])
    }
    
    public func conversationInfoClicked() {
        methodChannel.invokeMethod("onConversationInfoClicked", arguments: "clicked")
    }
    
    public func conversationResolved(conversationId: String) {
        
    }

    func convertDictToString(dict: NSDictionary) -> String {
        guard let data =  try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return ""
        }
        return String(data:data, encoding:.utf8) ?? ""
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }}
extension String {
    
    func convertToDictionary() -> [String: Any]? {
             if let data = data(using: .utf8) {
                 return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
             }
             return nil
         }
}

extension ALUserDetail {
    func toDictionary() -> [String: Any] {
         var dict: [String: Any] = [:]
         dict["userId"] = userId
         dict["connected"] = connected
         dict["lastSeenAtTime"] = lastSeenAtTime
         dict["unreadCount"] = unreadCount
         dict["fullName"] = displayName
         dict["userDetailDBObjectId"] = userDetailDBObjectId
         dict["imageLink"] = imageLink
         dict["contactNumber"] = contactNumber
         dict["userStatus"] = userStatus
         dict["keyArray"] = keyArray
         dict["valueArray"] = valueArray
         dict["userIdString"] = userIdString
         dict["userTypeId"] = userTypeId
         dict["deletedAtTime"] = deletedAtTime
         dict["roleType"] = roleType
         dict["metadata"] = metadata
         dict["notificationAfterTime"] = notificationAfterTime
         dict["emailId"] = email
         dict["status"] = status
         return dict
     }
}
