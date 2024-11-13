//
//  IngredientsHeaderRow.swift
//  Pizza
//
//  Created by Balázs Kilvády on 6/21/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct IngredientsHeaderRow: View {
    let data: IngredientsHeaderRowData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Image(.bgWood)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                data.image.map {
                    $0
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                }
            }
            Text(localizable: .ingredientsSectionTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.text)
                .padding(12)
        }
    }
}

#if DEBUG
#Preview {
    IngredientsHeaderRow(data: .init(image: nil))
}
#endif
