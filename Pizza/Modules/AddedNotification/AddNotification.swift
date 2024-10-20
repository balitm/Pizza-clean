//
//  AddNotification.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 19..
//

import SwiftUI

final class AddNotificationModel: ObservableObject {
    private var timer = Timer()
    var onFire: (() -> Void)?

    func start(with timeout: TimeInterval = kAddTimeout) {
        timer = Timer.scheduledTimer(
            withTimeInterval: timeout,
            repeats: false
        ) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            stop()
        }
    }

    func stop() {
        onFire?()
    }

    func cancel() {
        timer.invalidate()
    }
}

struct AddNotification: View {
    @EnvironmentObject private var alertHelper: AlertHelper
    @StateObject private var addNotificationModel = AddNotificationModel()
    var onNavigate: () -> Void

    var body: some View {
        Text(localizable: .addedNotification)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.tint)
            }
            .padding(.horizontal, 16)
            .onTapGesture {
                addNotificationModel.stop()
            }
            .onAppear {
                addNotificationModel.onFire = onFire
                addNotificationModel.start()
            }
            .onDisappear {
                addNotificationModel.cancel()
                onNavigate()
            }
    }

    func onFire() {
        alertHelper.hideAlert()
    }
}

#if DEBUG
#Preview {
    AddNotification {}
        .environmentObject(AlertHelper())
}
#endif
