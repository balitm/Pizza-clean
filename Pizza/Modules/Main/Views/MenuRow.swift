//
//  MenuRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/8/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct MenuRow: View {
    let data: MenuRowData

    var body: some View {
        ZStack(alignment: .top) {
            Image(.bgWood)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 128, alignment: .top)
                .clipped()
            if let url = data.url {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fill)
                .frame(height: 179)
                .clipped()
            }
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(data.nameText)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(data.ingredientsText)
                        .font(.system(size: 14))
                        .foregroundStyle(.text)
                }
                Button {
                    self.data.addToCart()
                } label: {
                    HStack(spacing: 4) {
                        Image(.icCartButton)
                            .resizable()
                            .foregroundStyle(.price)
                            .frame(width: 14, height: 14)
                            .scaledToFit()
                        Text(data.priceText)
                            .foregroundStyle(.price)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(width: 64, height: 28)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.button)
                    )
                }
            }
            .padding()
            .background(.regularMaterial, in: Rectangle())
            .padding(.top, 109)
        }
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
                    MenuRow(data: .preview(from: pizzas, at: 0))
                    MenuRow(data: .preview(from: pizzas, at: 1))
                        .environment(\.colorScheme, .dark)
                }
            }
            .task {
                let service = Container.shared.menuUseCase()
                try? await service.initialize()
                pizzas = await service.pizzas()
            }
        }
    }

    return AsyncTestView()
}
#endif
