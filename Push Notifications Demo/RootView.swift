//  Copyright © 2024 Dmitrijs Beloborodovs. All rights reserved.

import SwiftUI

struct RootView: View {
    @Bindable var viewModel: RootViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Push notifications status:")
                Spacer()
                VStack {
                    Text("notDetermined")
                        .bold(viewModel.status == .notDetermined)
                    Text("denied")
                        .bold(viewModel.status == .denied)
                    Text("authorized")
                        .bold(viewModel.status == .authorized)
                    Text("provisional")
                        .bold(viewModel.status == .provisional)
                    Text("ephemeral")
                        .bold(viewModel.status == .ephemeral)
                }
            }
            .padding()

            Button("Check status", systemImage: "arrow.clockwise") {
                Task { await viewModel.checkStatus() }
            }
            .padding()

            Picker("", selection: $viewModel.requestType) {
                Text("Explicit").tag(0)
                Text("Provisional").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            Button("Request permission", systemImage: "gear.badge.questionmark") {
                Task { await viewModel.requestPermission() }
            }
            .padding()

            Spacer()

            VStack {
                HStack {
                    Text("Title:").bold()
                    Text(viewModel.notificationTitle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Subtitle:").bold()
                    Text(viewModel.notificationSubtitle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Body:").bold()
                    Text(viewModel.notificationBody)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()

            Spacer()
        }
    }
}

#if DEBUG

#Preview {
    RootView(viewModel: RootViewModel())
}

#endif
