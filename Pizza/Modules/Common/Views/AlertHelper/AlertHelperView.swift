import SwiftUI
import Domain
import os

struct AlertHelperView<Content: View>: View {
    @EnvironmentObject private var _navHelper: AlertHelper
    @State private var _alert: AlertHelper.IdentifiableAlert?
    private let _content: Content

    @State private var show = false

    init(@ViewBuilder content: () -> Content) {
        _content = content()
    }

    var body: some View {
        ZStack {
            _content
            // .blur(radius: _navHelper.isTouchOutside ? 0 : 5)

            ZStack(alignment: _alert?.alignment ?? .center) {
                if let _alert {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(_alert.opacity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if _navHelper.isTouchOutside {
                                _navHelper.hideAlert()
                            }
                        }
                }

                VStack {
                    if let _alert {
                        _alert.view
                    }
                }
                .padding(_alert?.padding ?? EdgeInsets())

                ZStack {
                    if let overlays = _alert?.overlays {
                        ForEach(overlays) { overlay in
                            overlay.view
                        }
                    }
                }
                .onTapGesture {
                    if _navHelper.isTouchOutside {
                        _navHelper.hideAlert()
                    }
                }
                .padding(_alert?.padding ?? EdgeInsets())
            }
            .zIndex(1)
        }
        .onReceive(_navHelper.$alertView) { alertView in
            withAnimation {
                // if alertView == nil {
                //     DLog(l: .trace, "#> hide alert")
                // } else {
                //     DLog(l: .trace, "#> show alert")
                // }
                _alert = alertView
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if _navHelper.noNetView {
                Text("No net")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .foregroundColor(.white)
                    .background(.red)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.default, value: _navHelper.noNetView)
    }
}
