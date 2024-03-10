//  Copyright © 2024 Dmitrijs Beloborodovs. All rights reserved.

import Foundation
import UserNotifications

@Observable
class RootViewModel  {
    var status: UNAuthorizationStatus = .notDetermined
    var requestType: Int = 0

    var notificationTitle: String = ""
    var notificationSubtitle: String = ""
    var notificationBody: String = ""
    var customAction: String = ""

    init() {
        Task { await checkStatus() }
        registerCustomActions()
    }

    func registerCustomActions() {
        // Define the custom actions
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_PAYMENT",
            title: "Accept",
            options: [.authenticationRequired]
        )
        let declineAction = UNNotificationAction(
            identifier: "DECLINE_PAYMENT",
            title: "Decline",
            options: [.destructive]
        )
        // Define the notification type
        let incomingPaymentCategory = UNNotificationCategory(
            identifier: "PAY_IN",
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "%u incoming payments",
            options: .customDismissAction
        )
        // Register the notification type
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([incomingPaymentCategory])
    }

    func requestPermission() async {
        let opt1: UNAuthorizationOptions = [.alert, .badge, .sound]
        let opt2: UNAuthorizationOptions = [.provisional]
        do {
            try await UNUserNotificationCenter.current()
                .requestAuthorization(options: requestType == 0 ? opt1 : opt2)
            await checkStatus()
        } catch{
            print(error)
        }
    }

    @MainActor
    func checkStatus() async {
        status = await UNUserNotificationCenter.current()
            .notificationSettings().authorizationStatus
    }

    @MainActor
    func notificationReceived(with payload: [AnyHashable : Any]) {
        clearFields()
        guard let aps = payload["aps"] as? [AnyHashable : Any],
              let alert = aps["alert"] as? [AnyHashable : Any] else { return }
        notificationTitle = alert["title"] as? String ?? ""
        notificationSubtitle = alert["subtitle"] as? String ?? ""
        notificationBody = alert["body"] as? String ?? ""

        if let customID = payload["my_id"] as? String {
            debugPrint("My custom ID recevied \(customID)")
        }
    }

    @MainActor 
    func backgroundTask(with userInfo: [AnyHashable : Any]) {
        clearFields()

        customAction = userInfo["my_id"] as? String ?? ""
    }
}

private extension RootViewModel {

    func clearFields() {
        notificationTitle = ""
        notificationSubtitle = ""
        notificationBody = ""
        customAction = ""
    }
}
