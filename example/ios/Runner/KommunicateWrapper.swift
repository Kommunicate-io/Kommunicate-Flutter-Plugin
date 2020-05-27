//
//  KommunicateWrapper.swift
//  KommunicateObjcSample
//
//  Created by Mukesh Thawani on 04/10/18.
//  Copyright © 2018 mukesh. All rights reserved.
//

import Foundation
import Kommunicate
import UserNotifications

@objc public class KommunicateWrapper: NSObject {

    @objc public static let shared = KommunicateWrapper()

    @objc func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {

        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)")  // (SWIFT = 3) : TOKEN PARSING

        var deviceTokenString: String = ""
        for i in 0..<deviceToken.count
        {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")

        if (KMUserDefaultHandler.getApnDeviceToken() != deviceTokenString)
        {
            let kmRegisterUserClientService: KMRegisterUserClientService = KMRegisterUserClientService()
            kmRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { (response, error) in
                print ("REGISTRATION_RESPONSE :: \(String(describing: response))")
            })
        }
    }

    @objc func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForNotification()
        KMPushNotificationHandler.shared.dataConnectionNotificationHandlerWith(Kommunicate.defaultConfiguration, Kommunicate.kmConversationViewConfiguration)
        let kmApplocalNotificationHandler : KMAppLocalNotification =  KMAppLocalNotification.appLocalNotificationHandler()
        kmApplocalNotificationHandler.dataConnectionNotificationHandler()
        return true
    }

    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        print("APP_ENTER_IN_BACKGROUND")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "APP_ENTER_IN_BACKGROUND"), object: nil)
    }

    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        KMPushNotificationService.applicationEntersForeground()
        print("APP_ENTER_IN_FOREGROUND")

        NotificationCenter.default.post(name: Notification.Name(rawValue: "APP_ENTER_IN_FOREGROUND"), object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    @objc func applicationWillTerminate(application: UIApplication) {
        KMDbHandler.sharedInstance().saveContext()
    }

    @objc func connectUser(userId: String,
                           password: String? = nil,
                           displayName: String? = nil,
                           emailId: String? = nil,
                           applicationId: String,
                           completion : @escaping (_ response: String?, _ error: NSError?) -> Void) {
        guard let user = KMUser(userId: userId, password: password, email: emailId, andDisplayName: displayName) else {
            completion(nil, NSError(domain: "KMUserGeneration", code: 111, userInfo: nil))
            return
        }
        user.applicationId = applicationId
        Kommunicate.registerUser(user) { (response, error) in
            if error == nil {
                completion(response?.userKey, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let service = KMPushNotificationService()
        let dict = notification.request.content.userInfo
        guard !service.isKommunicateNotification(dict) else {
            service.processPushNotification(dict, appState: UIApplication.shared.applicationState)
            completionHandler([])
            return
        }
        completionHandler([.sound, .badge, .alert])
    }

    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let service = KMPushNotificationService()
        let dict = response.notification.request.content.userInfo
        if service.isApplozicNotification(dict) {
            service.processPushNotification(dict, appState: UIApplication.shared.applicationState)
        }
        completionHandler()
    }

    func registerForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
