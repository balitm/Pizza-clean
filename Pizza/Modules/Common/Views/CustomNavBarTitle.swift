import SwiftUI

// import SwiftUIIntrospect

extension View {
    @ViewBuilder
    func customNavBarTitle(_ title: String) -> some View {
        modifier(CustomNavBarTitle(title: title))
    }
}

struct CustomNavBarTitle: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
        // .introspect(.viewController, on: .iOS(.v15, .v16, .v17), scope: .ancestor) { view in
        //     view.navigationItem.backButtonTitle = ""
        // }
    }
}
