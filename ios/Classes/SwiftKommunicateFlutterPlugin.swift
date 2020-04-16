import Flutter
import UIKit
import Kommunicate
import Applozic

public class SwiftKommunicateFlutterPlugin: NSObject, FlutterPlugin, KMPreChatFormViewControllerDelegate {
    var appId : String? = nil;
    var agentIds: [String]? = [];
    var botIds: [String]? = [];
    var createOnly: Bool = false
    var isSingleConversation: Bool = true;
    var callback: FlutterResult? 
    
    override init() {
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "kommunicate_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftKommunicateFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if(call.method == "buildConversation") {
            do {
                guard let jsonObj = call.arguments as? Dictionary<String, Any> else {
                    return
                }
                
                self.callback = result
                var withPrechat : Bool = false
                var kmUser : KMUser? = nil
                
                if jsonObj["appId"] != nil {
                    appId = jsonObj["appId"] as? String
                }
                
                if jsonObj["withPreChat"] != nil {
                    withPrechat = jsonObj["withPreChat"] as! Bool
                }
                
                if jsonObj["isSingleConversation"] != nil{
                    self.isSingleConversation = jsonObj["isSingleConversation"] as! Bool
                }
                
                if(jsonObj["createOnly"] != nil){
                    self.createOnly = jsonObj["createOnly"] as! Bool
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
                        if jsonObj["kmUser"] != nil{
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
                    }else{
                        DispatchQueue.main.async {
                            let controller = KMPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
                            controller.delegate = self
                            UIApplication.topViewController()?.present(controller, animated: false, completion: nil)
                        }
                    }
                }
            }catch _ as NSError{
                
            }
        } else if(call.method == "logout") {
            Kommunicate.logoutUser()
            result(String("Success"))
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
                let userClientService = ALUserClientService()
                userClientService.updateUserDisplayName(kmUser["displayName"] as? String, andUserImageLink: kmUser["imageLink"] as? String, userStatus: kmUser["status"] as? String, metadata: kmUser["metadata"] as? NSMutableDictionary) { (_, error) in
                    guard error == nil else {
                        self.sendErrorResultWithCallback(result: result, message: error.localizedDescription)
                        return
                    }
                    self.sendSuccessResultWithCallback(result: result, message: "Success")
                }
            } else {
                sendErrorResultWithCallback(result: result, message: "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the user details")
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func openParticularConversation(_ conversationId: String,_ skipConversationList: Bool, _ callback: @escaping FlutterResult) -> Void {
        DispatchQueue.main.async{
            if let top = UIApplication.topViewController(){
                Kommunicate.showConversationWith(groupId: conversationId, from: top, completionHandler: ({ (shown) in
                    if(shown){
                        callback(conversationId)
                    }else{
                        self.sendErrorResultWithCallback(result: callback, message: "Failed to launch conversation with conversationId : " + conversationId)
                    }
                }))
            }else{
                self.sendErrorResultWithCallback(result: callback, message: "Failed to launch conversation with conversationId : " + conversationId)
            }}
    }
    
    public func closeButtonTapped() {
        UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
    }
    
    public func userSubmittedResponse(name: String, email: String, phoneNumber: String) {
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
        
        Kommunicate.registerUser(kmUser, completion:{
            response, error in
            guard error == nil else{
                self.sendErrorResult(message: "Unable to login")
                return
            }
            self.handleCreateConversation()
        })
    }
    
    func handleCreateConversation(){
        Kommunicate.createConversation(userId: KMUserDefaultHandler.getUserId(),
                                       agentIds: self.agentIds ?? [],
                                       botIds: self.botIds,
                                       useLastConversation: self.isSingleConversation,
                                       completion: { response in
                                        guard !response.isEmpty else{
                                            self.sendErrorResult(message: "Unable to create conversation")
                                            return
                                        }
                                        if self.createOnly {
                                            self.sendSuccessResult(message: String(response))
                                        } else {
                                            self.openParticularConversation(response, true, self.callback!)
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
