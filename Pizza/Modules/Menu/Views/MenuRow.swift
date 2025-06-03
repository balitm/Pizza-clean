//
//  MenuRow.swift
//  Pizza
//
//  Created by Balázs Kilvády on 6/8/20.
//  Copyright 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct MenuRow: View {
    let store: StoreOf<MenuRowFeature>
    var onTapDetails: ((MenuRowData) -> Void)?
    var onAddToCart: ((Int) -> Void)?

    var body: some View {
        Button {
            store.send(.onTapDetails)
        } label: {
            rowView
        }
        .onAppear {
            store.send(.downloadImage)
        }
    }

    var rowView: some View {
        let state = store.state

        return ZStack(alignment: .top) {
            Image(.bgWood)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 128, alignment: .top)
                .clipped()

            if let image = state.data.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 179)
                    .clipped()
            } else if state.data.pizza.imageUrl != nil {
                ProgressView()
                    .tint(.gray)
                    .frame(height: 128)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(state.data.pizza.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(state.data.ingredientsText)
                        .font(.system(size: 14))
                        .foregroundStyle(.text)
                }
                Button {
                    store.send(.onTapAddToCart)
                } label: {
                    HStack(spacing: 4) {
                        Image(.icCartButton)
                            .resizable()
                            .foregroundStyle(.price)
                            .frame(width: 14, height: 14)
                            .scaledToFit()
                        Text(state.data.priceText)
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
                    MenuRow(
                        store: Store(
                            initialState: MenuRowFeature.State(
                                data: MenuRowData(
                                    index: 0,
                                    basePrice: pizzas.basePrice,
                                    pizza: pizzas.pizzas[0]
                                )
                            )
                        ) {
                            MenuRowFeature()
                        }
                    )
                    MenuRow(
                        store: Store(
                            initialState: MenuRowFeature.State(
                                data: MenuRowData(
                                    index: 1,
                                    basePrice: pizzas.basePrice,
                                    pizza: pizzas.pizzas[1]
                                )
                            )
                        ) {
                            MenuRowFeature()
                        }
                    )
                    .environment(\.colorScheme, .dark)
                }
            }
            .task {
                let component = Container.shared.componentsModel()
                try? await component.initialize()
                pizzas = await component.pizzas
            }
        }
    }

    return AsyncTestView()
}
#endif
