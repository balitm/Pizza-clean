//
//  CustomNotification.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 19..
//

import SwiftUI

final class CustomNotificationModel: ObservableObject {
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

struct CustomNotification: View {
    @EnvironmentObject private var alertHelper: AlertHelper
    @StateObject private var addNotificationModel = CustomNotificationModel()
    let text: LocalizedStringKey
    var onNavigate: () -> Void

    var body: some View {
        Text(text)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.accent)
            }
            .padding(.horizontal, 16)
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
    CustomNotification(text: .localizable(.addedNotification)) {}
        .environmentObject(AlertHelper())
}
#endif
