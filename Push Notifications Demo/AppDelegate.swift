//  Copyright © 2024 Dmitrijs Beloborodovs. All rights reserved.

import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {

    public let rootViewModel: RootViewModel = RootViewModel()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("\(#function)\n\(launchOptions ?? [:])")

        UNUserNotificationCenter.current().delegate = self

        // Note: intialize firebase before registering to notification
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("\(#function)\n[\(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())]")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("\(#function)\n\(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any]
    ) async -> UIBackgroundFetchResult {
        print("\(#function)\n\(userInfo)")
        rootViewModel.backgroundTask(with: userInfo)
        // perform any task in less than 30 sec
        return .newData
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
        let userInfo = notification?.request.content.userInfo ?? [:]
        print("\(#function)\n\(userInfo)")
        rootViewModel.displayConfigSettings()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        print("\(#function)\n\(userInfo)")
        rootViewModel.notificationReceived(with: userInfo)
        /// return an array with element to display
        return [.sound, .banner, .badge, .list]
        /// return empty list if no UI needed for notification
        // return []
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        print("\(#function)\n\(userInfo)")
        rootViewModel.notificationReceived(with: userInfo)

        // Perform the task associated with the action
        switch response.actionIdentifier {
            case "ACCEPT_PAYMENT":
                // proceed with payment accept
                break
            case "DECLINE_PAYMENT":
                // proceed with payment decline
                break
            default:
                break
        }
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("\(#function)\nFirebase registration token: \(String(describing: fcmToken))")
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}
