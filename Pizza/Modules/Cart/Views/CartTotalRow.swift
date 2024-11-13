//
//  CartTotalRow.swift
//  Pizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI

struct CartTotalRow: View {
    let data: CartTotalRowData

    var body: some View {
        HStack(spacing: 0) {
            Text(localizable: .total)
                .foregroundStyle(.text)
                .fontWeight(.bold)
            Spacer()
            Text(data.priceText)
                .foregroundStyle(.text)
                .fontWeight(.bold)
        }
        .padding(.leading, 54)
        .padding(.trailing, 12)
        .frame(height: 44)
    }
}

#if DEBUG
#Preview {
    CartTotalRow(data: CartTotalRowData(price: 12.5))
}
#endif
