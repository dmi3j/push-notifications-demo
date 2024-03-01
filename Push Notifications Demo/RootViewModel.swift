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

    init() {
        Task { await checkStatus() }
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
        guard let aps = payload["aps"] as? [AnyHashable : Any],
              let alert = aps["alert"] as? [AnyHashable : Any] else { return }
        notificationTitle = alert["title"] as? String ?? ""
        notificationSubtitle = alert["subtitle"] as? String ?? ""
        notificationBody = alert["body"] as? String ?? ""
    }
}
