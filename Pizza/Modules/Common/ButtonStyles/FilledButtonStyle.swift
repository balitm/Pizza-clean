//
//  FilledButtonStyle.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 22..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(.accent)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension SwiftUI.ButtonStyle where Self == FilledButtonStyle {
    static var filled: Self { Self() }
}

#if DEBUG
#Preview {
    Button("error") {}
        .buttonStyle(.filled)
        .padding()
}
#endif
