//  Copyright © 2024 Dmitrijs Beloborodovs. All rights reserved.

import Foundation
import UserNotifications

@Observable
class RootViewModel  {
    var status: UNAuthorizationStatus = .notDetermined
    var requestType: Int = 0

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
}
