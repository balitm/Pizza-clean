//
//  DrinkRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

struct DrinkRow: View {
    let data: DrinkRowData

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "plus")
                .foregroundStyle(.accent)
                .font(.system(size: 11, weight: .regular))
                .frame(width: 54)
            Text(data.name)
                .foregroundStyle(.text)
            Spacer()
            Text(data.priceText)
                .foregroundStyle(.text)
        }
        .padding(.trailing, 16)
    }
}

#if DEBUG
#Preview {
    DrinkRow(data: .preview)
}
#endif
