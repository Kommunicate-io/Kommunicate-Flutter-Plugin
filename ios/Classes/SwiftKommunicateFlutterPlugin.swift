import Flutter
import UIKit
import Kommunicate
import KommunicateCore_iOS_SDK

public class SwiftKommunicateFlutterPlugin: NSObject, FlutterPlugin, KMPreChatFormViewControllerDelegate {
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
    
    
    override init() {
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "kommunicate_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftKommunicateFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.callback = result
        
        if(call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if(call.method == "isLoggedIn") {
            result(Kommunicate.isLoggedIn)
        } else if(call.method == "login") {
            guard var userDict = call.arguments as? Dictionary<String, Any> else {
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
            let kmUser = KMUser()
            kmUser.userId = Kommunicate.randomId()
            kmUser.applicationId = appId
            
            Kommunicate.registerUser(kmUser, completion: {
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
            guard let clientConversationId = call.arguments as? String else {
                self.sendErrorResultWithCallback(result: result, message: "Invalid or empty clientConversationId")
                return
            }
            self.openParticularConversation(clientConversationId, true, result)
        } else if(call.method == "updateTeamId") {
            
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
                guard let jsonObj = call.arguments as? Dictionary<String, Any> else {
                    return
                }
                
                var withPrechat : Bool = false
                var kmUser : KMUser? = nil
                
                if jsonObj["appId"] != nil {
                    appId = jsonObj["appId"] as? String
                }
                
                if jsonObj["withPreChat"] != nil {
                    withPrechat = jsonObj["withPreChat"] as! Bool
                }
                
                if jsonObj["isSingleConversation"] != nil {
                    self.isSingleConversation = jsonObj["isSingleConversation"] as! Bool
                }
                
                if jsonObj["createOnly"] != nil {
                    self.createOnly = jsonObj["createOnly"] as! Bool
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
                
                if let messageMetadataStr = (jsonObj["messageMetadata"] as? String)?.data(using: .utf8) {
                    if let messageMetadataDict = try JSONSerialization.jsonObject(with: messageMetadataStr, options : .allowFragments) as? Dictionary<String,Any> {
                        Kommunicate.defaultConfiguration.messageMetadata = messageMetadataDict
                    }
                }
                
                let agentIds = jsonObj["agentIds"] as? [String]
                let botIds = jsonObj["botIds"] as? [String]
                
                self.agentIds = agentIds
                self.botIds = botIds
                
                if Kommunicate.isLoggedIn{
                    self.handleCreateConversation()
                }else{
                    if jsonObj["appId"] != nil {
                        Kommunicate.setup(applicationId: jsonObj["appId"] as! String)
                    }
                    
                    if !withPrechat {
                        if jsonObj["kmUser"] != nil {
                            var jsonSt = jsonObj["kmUser"] as! String
                            jsonSt = jsonSt.replacingOccurrences(of: "\\\"", with: "\"")
                            jsonSt = "\(jsonSt)"
                            kmUser = KMUser(jsonString: jsonSt)
                            kmUser?.applicationId = appId
                        } else {
                            kmUser = KMUser.init()
                            kmUser?.userId = Kommunicate.randomId()
                            kmUser?.applicationId = appId
                        }
                        
                        Kommunicate.registerUser(kmUser!, completion:{
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
            guard let chatContext = call.arguments as? Dictionary<String, Any> else {
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
            guard let kmUser = call.arguments as? Dictionary<String, Any> else {
                sendErrorResultWithCallback(result: result, message: "Invalid kmUser object")
                return
            }
            if(Kommunicate.isLoggedIn) {
                self.updateUser(displayName: kmUser["displayName"] as? String, imageLink: kmUser["imageLink"] as? String, status: kmUser["status"] as? String, metadata: kmUser["metadata"] as? NSMutableDictionary, phoneNumber: kmUser["contactNumber"] as? String, email: kmUser["email"] as? String, result: result)
            } else {
                sendErrorResultWithCallback(result: result, message: "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the user details")
            }
        } else if(call.method == "unreadCount") {
            result(ALUserService().getTotalUnreadCount()?.stringValue)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func openParticularConversation(_ conversationId: String,_ skipConversationList: Bool, _ callback: @escaping FlutterResult) -> Void {
        DispatchQueue.main.async{
            let alChannelService = ALChannelService()
            var conversationID = String()
            if Int(conversationId) != nil {
                alChannelService.getChannelInformation(NSNumber(value: Int(conversationId)!), orClientChannelKey: nil) { (channel) in
                    if channel != nil && channel?.clientChannelKey != nil {
                        conversationID = channel!.clientChannelKey
                    }
                }
            } else {
                conversationID = conversationId
            }
            if let top = UIApplication.topViewController(){
                Kommunicate.showConversationWith(groupId: conversationID, from: top, completionHandler: ({ (shown) in
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
    
    func updateUser (displayName: String?, imageLink : String?, status: String?, metadata: NSMutableDictionary?,phoneNumber: String?,email : String?, result: FlutterResult!) {
        
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
                alContact?.metadata = metadata
            }
            ALContactDBService().updateContact(inDatabase: alContact)
            self.sendSuccessResultWithCallback(result: result, message: "Success")
        })
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
