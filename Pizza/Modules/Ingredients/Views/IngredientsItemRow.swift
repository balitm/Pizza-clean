//
//  IngredientsItemRow.swift
//  Pizza
//
//  Created by Balázs Kilvády on 6/21/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct IngredientsItemRow: View {
    let data: IngredientsItemRowData

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "checkmark")
                .foregroundStyle(.accent)
                .font(.system(size: 10, weight: .bold))
                .frame(width: 54)
                .opacity(data.isContained ? 1.0 : 0.0)
            Text(data.name)
                .foregroundStyle(.text)
            Spacer()
            Text(data.priceText)
                .foregroundStyle(.text)
                .padding(.trailing, 16)
        }
        .frame(height: 44)
    }
}

#if DEBUG
import Factory

#Preview {
    struct AsyncTestView: View {
        @State var pizzas: Pizzas?

        var body: some View {
            VStack(spacing: 10) {
                if let pizzas {
                    IngredientsItemRow(data: .preview(from: pizzas, at: 0, isContained: true))
                    IngredientsItemRow(data: .preview(from: pizzas, at: 1, isContained: false))
                }
            }
            .task {
                pizzas = try? await initPizzas()
            }
        }
    }

    return AsyncTestView()
}
#endif
