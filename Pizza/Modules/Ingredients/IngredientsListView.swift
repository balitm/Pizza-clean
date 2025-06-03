//
//  IngredientsListView.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright 2024 kil-dev. All rights reserved.

import SwiftUI
import ComposableArchitecture
import Domain

struct IngredientsListView: View {
    @Environment(AlertHelper.self) private var alertHelper
    let store: StoreOf<IngredientsFeature>

    var body: some View {
        VStack(spacing: 0) {
            List {
                header(pizzaData: store.pizzaData)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)

                ForEach(store.listData) { itemData in
                    Button {
                        store.send(.selectIngredient(itemData.index))
                    } label: {
                        IngredientsItemRow(data: itemData)
                    }
                    .listRowInsets(.init())
                }
            }

            if !store.showCartText.isEmpty {
                footer(
                    text: store.showCartText,
                    action: { store.send(.addToCart) }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.default, value: store.showCartText.isEmpty)
        .listStyle(.plain)
        .navigationTitle(store.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: store.alertKind) { _, alertKind in
            handleAlert(alertKind, store)
        }
    }

    @ViewBuilder
    private func header(pizzaData: MenuRowData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Image(.bgWood)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()

                if let image = pizzaData.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                } else if pizzaData.pizza.imageUrl != nil {
                    ProgressView()
                        .tint(.secondary)
                        .frame(height: 128)
                }
            }

            Text(localizable: .ingredientsSectionTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.text)
                .padding(12)
        }
    }

    @ViewBuilder
    private func footer(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                .foregroundStyle(.price)
                .contentShape(Rectangle())
        }
        .background {
            Color.button
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func handleAlert(
        _ alertKind: IngredientsFeature.State.AlertKind,
        _ store: StoreOf<IngredientsFeature>
    ) {
        switch alertKind {
        case .added:
            alertHelper.showAlert(
                isTouchOutside: true,
                alignment: .top
            ) {
                AddedNotification(text: .localizable(.addedNotification)) {
                    store.send(.delegate(.navigateToCart))
                } onDismiss: {
                    store.send(.alert(.none))
                }
                .transition(.move(edge: .top))
            }
        case .none:
            break
        }
    }
}

#if DEBUG
import Factory

#Preview {
    struct AsyncTestView: View {
        @State var pizzas: Pizzas?

        var body: some View {
            NavigationStack {
                VStack {
                    if let pizzas {
                        IngredientsListView(
                            store: Store(
                                initialState: IngredientsFeature.State(
                                    pizzaData: .preview(from: pizzas, at: 0)
                                )
                            ) {
                                IngredientsFeature()
                            }
                        )
                    }
                }
                .task {
                    let component = Container.shared.componentsModel()
                    try? await component.initialize()
                    pizzas = await component.pizzas
                }
            }
        }
    }

    return AsyncTestView()
        .environment(AlertHelper())
}

#endif
