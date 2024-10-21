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
    let viewModel: MenuRowData

    var body: some View {
        ZStack(alignment: .top) {
            Image(.bgWood)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 128, alignment: .top)
                .clipped()
            if let url = viewModel.url {
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
                    Text(viewModel.nameText)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.ingredientsText)
                        .font(.system(size: 14))
                        .foregroundStyle(.text)
                }
                Button {
                    self.viewModel.addToCart()
                } label: {
                    HStack(spacing: 4) {
                        Image(.icCartButton)
                            .resizable()
                            .foregroundStyle(.price)
                            .frame(width: 14, height: 14)
                            .scaledToFit()
                        Text(viewModel.priceText)
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
                    MenuRow(viewModel: MenuRowData(index: 0,
                                                   basePrice: pizzas.basePrice,
                                                   pizza: pizzas.pizzas[0]) { _ in })
                    MenuRow(viewModel: MenuRowData(index: 1,
                                                   basePrice: pizzas.basePrice,
                                                   pizza: pizzas.pizzas[1]) { _ in })
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
