//
//  SuccessView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/7/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI

struct SuccessView: View {
    @EnvironmentObject private var router: MainRouter

    var body: some View {
        VStack {
            VStack {
                Text(localizable: .cartSuccessThanx)
                    .foregroundStyle(.accent)
                    .font(.system(size: 34).italic())
                    .multilineTextAlignment(.center)
            }
            .frame(maxHeight: .infinity)

            footer
        }
        .contentShape(Rectangle())
        .onTapGesture {
            router.popToRoot()
        }
    }

    var footer: some View {
        Rectangle()
            .fill(.accent)
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
            .background {
                Color.accent
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}

#if DEBUG
#Preview {
    SuccessView()
        .environmentObject(MainRouter())
}
#endif
