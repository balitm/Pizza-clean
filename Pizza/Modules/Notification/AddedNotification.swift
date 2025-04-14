//
//  AddedNotification.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 19..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI

@MainActor
@Observable final class CustomNotificationModel {
    private var timer = Timer()
    var onFire: (@MainActor () -> Void)?

    func start(with timeout: TimeInterval = kAddTimeout) {
        timer = Timer.scheduledTimer(
            withTimeInterval: timeout,
            repeats: false
        ) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                stop()
            }
        }
    }

    func stop() {
        onFire?()
    }

    func cancel() {
        timer.invalidate()
    }
}

struct AddedNotification: View {
    @Environment(AlertHelper.self) private var alertHelper
    @State private var addNotificationModel = CustomNotificationModel()
    let text: LocalizedStringKey
    var onNavigate: () -> Void

    var body: some View {
        CustomNotification(text: text)
            .onTapGesture {
                addNotificationModel.stop()
                onNavigate()
            }
            .onAppear {
                addNotificationModel.onFire = onFire
                addNotificationModel.start()
            }
            .onDisappear {
                addNotificationModel.cancel()
            }
    }

    func onFire() {
        alertHelper.hideAlert()
    }
}

#if DEBUG
#Preview {
    AddedNotification(text: .localizable(.addedNotification)) {}
        .environment(AlertHelper())
}
#endif
