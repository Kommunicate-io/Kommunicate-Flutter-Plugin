import UIKit
import Flutter
import UserNotifications
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        UNUserNotificationCenter.current().delegate = self
        KommunicateWrapper.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        KommunicateWrapper.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: { options in
            completionHandler(options)
        })
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        KommunicateWrapper.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: {
            completionHandler()
        })
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        KommunicateWrapper.shared.applicationWillTerminate(application: application)
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        print("APP_ENTER_IN_FOREGROUND")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)") // (SWIFT = 3) : TOKEN PARSING
        KommunicateWrapper.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}
