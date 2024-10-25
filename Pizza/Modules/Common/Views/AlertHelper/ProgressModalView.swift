import SwiftUI

/// Progress modal view (with the animated hourglass).
struct ProgressModalView: View {
    var body: some View {
        ProgressView()
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.black
            .opacity(0.6)
            .ignoresSafeArea()

        ProgressModalView()
    }
}
#endif
