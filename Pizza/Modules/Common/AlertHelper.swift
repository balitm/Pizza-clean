import SwiftUI

final class AlertHelper: ObservableObject {
    struct AnyOverlayView: Identifiable {
        let id = UUID()
        let view: AnyView
    }

    struct IdentifiableAlert {
        let view: AnyView
        let overlays: [AnyOverlayView]?
        let padding: EdgeInsets
        let alignment: Alignment
        let opacity: CGFloat

        init(view: AnyView, overlays: [AnyOverlayView]?,
             padding: EdgeInsets, alignment: Alignment,
             opacity: CGFloat) {
            self.view = view
            self.overlays = overlays
            self.padding = padding
            self.alignment = alignment
            self.opacity = opacity
        }

        fileprivate init(view: AnyView, overlayViews: [AnyView]?,
                         padding: EdgeInsets, alignment: Alignment,
                         opacity: CGFloat) {
            self.view = view
            overlays = overlayViews?.map { AnyOverlayView(view: $0) }
            self.padding = padding
            self.alignment = alignment
            self.opacity = opacity
        }
    }

    /// Alert/modal popup to show.
    @Published private(set) var alertView: IdentifiableAlert?

    /// Let hide for touch up outside?
    var isTouchOutside = false

    /// Show general progress alert animation.
    func showProgress() {
        _showAlert(isTouchOutside: false,
                   AnyView(ProgressModalView()))
    }

    /// Show an alert (popup) view.
    /// - Parameters:
    ///   - isTouchOutside: is the alert can be closed with a tap outside?
    ///   - content: The content of the alert.
    func showAlert(isTouchOutside: Bool = false,
                   padding: EdgeInsets = EdgeInsets(),
                   alignment: Alignment = .center,
                   opacity: CGFloat = 0.6,
                   overlays: [AnyView]? = nil,
                   @ViewBuilder content: () -> some View) {
        _showAlert(
            isTouchOutside: isTouchOutside,
            IdentifiableAlert(view: AnyView(content()), overlayViews: overlays,
                              padding: padding, alignment: alignment,
                              opacity: opacity)
        )
    }

    func hideAlert() {
        isTouchOutside = false
        alertView = nil
    }
}

private extension AlertHelper {
    func _showAlert(isTouchOutside: Bool = false,
                    _ alert: IdentifiableAlert) {
        self.isTouchOutside = isTouchOutside
        alertView = alert
    }

    func _showAlert(isTouchOutside: Bool = false,
                    _ alert: AnyView) {
        self.isTouchOutside = isTouchOutside
        alertView = IdentifiableAlert(view: alert, overlays: nil,
                                      padding: EdgeInsets(), alignment: .center,
                                      opacity: 0.6)
    }
}
