//
//  CartItemRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct CartItemRow: View {
    let data: CartItemRowData

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "xmark")
                .foregroundStyle(.accent)
                .font(.system(size: 10, weight: .bold))
                .frame(width: 54)
            Text(data.name)
                .foregroundStyle(.text)
            Spacer()
            Text(data.priceText)
                .foregroundStyle(.text)
                .padding(.trailing, 12)
        }
        .frame(height: 44)
    }
}

#if DEBUG
#Preview {
    CartItemRow(data: .preview)
}
#endif
