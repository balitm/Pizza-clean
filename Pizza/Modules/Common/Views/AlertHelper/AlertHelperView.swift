import SwiftUI

struct AlertHelperView<Content: View>: View {
    @Environment(AlertHelper.self) private var alertHelper
    @State private var alert: AlertHelper.IdentifiableAlert?
    private let content: Content

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
        .onReceive(alertHelper.alertView) { alertView in
            withAnimation {
                alert = alertView
            }
        }
    }
}
