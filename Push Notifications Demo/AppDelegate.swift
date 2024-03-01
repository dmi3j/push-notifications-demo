//  Copyright © 2024 Dmitrijs Beloborodovs. All rights reserved.

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    public let rootViewModel: RootViewModel = RootViewModel()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("\(#function)\n\(launchOptions ?? [:])")
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("\(#function)\n[\(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())]")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("\(#function)\n\(error)")
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
        // return [.sound, .banner, .badge, .list]
        /// return empty list if no UI needed for notification
        return []
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        print("\(#function)\n\(userInfo)")
        rootViewModel.notificationReceived(with: userInfo)
    }
}
