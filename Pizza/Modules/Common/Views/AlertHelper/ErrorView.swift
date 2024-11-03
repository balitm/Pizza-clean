//
//  ErrorView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 22..
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    let action: () -> Void

    var body: some View {
        VStack {
            Text(localizable: .errorTitle)
                .font(.title3)
                .foregroundStyle(.accent)
            Text(error.localizedDescription)
            Divider()
            Button(.localizable(.errorAction)) { action() }
                .buttonStyle(.filled)
        }
        .padding(16)
        .background(.regularMaterial, in: Rectangle())
        .cornerRadius(16)
        .padding(32)
    }
}

import Domain

#Preview {
    ZStack {
        Color.black
            .opacity(0.6)
            .ignoresSafeArea()

        ErrorView(error: APIError(kind: .disabled)) {}
    }
}
