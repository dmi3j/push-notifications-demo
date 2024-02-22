//  Copyright © 2024 Dmitrijs Beloborodovs. All rights reserved.

import SwiftUI

@main
struct Push_Notifications_DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: delegate.rootViewModel)
        }
    }
}
