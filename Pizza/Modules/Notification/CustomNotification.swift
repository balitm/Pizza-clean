//
//  CustomNotification.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 31..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI

struct CustomNotification: View {
    let text: LocalizedStringKey

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
    }
}

#if DEBUG
#Preview {
    CustomNotification(text: .localizable(.noNetworkNotification))
}
#endif
