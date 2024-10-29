import SwiftUI
import Domain
import os

struct AlertHelperView<Content: View>: View {
    @EnvironmentObject private var alertHelper: AlertHelper
    @State private var alert: AlertHelper.IdentifiableAlert?
    private let content: Content

    @State private var show = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            // .blur(radius: _navHelper.isTouchOutside ? 0 : 5)

            ZStack(alignment: alert?.alignment ?? .center) {
                if let alert {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(alert.opacity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if alertHelper.isTouchOutside {
                                alertHelper.hideAlert()
                            }
                        }
                }

                VStack {
                    if let alert {
                        alert.view
                    }
                }
                .padding(alert?.padding ?? EdgeInsets())

                ZStack {
                    if let overlays = alert?.overlays {
                        ForEach(overlays) { overlay in
                            overlay.view
                        }
                    }
                }
                .onTapGesture {
                    if alertHelper.isTouchOutside {
                        alertHelper.hideAlert()
                    }
                }
                .padding(alert?.padding ?? EdgeInsets())
            }
            .zIndex(1)
        }
        .onReceive(alertHelper.$alertView) { alertView in
            withAnimation {
                // if alertView == nil {
                //     DLog(l: .trace, "#> hide alert")
                // } else {
                //     DLog(l: .trace, "#> show alert")
                // }
                alert = alertView
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if alertHelper.noNetView {
                Text("No net")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .foregroundColor(.white)
                    .background(.red)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.default, value: alertHelper.noNetView)
    }
}
