//
//  IngredientsListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Combine
import Domain

struct IngredientsListView: View {
    @EnvironmentObject private var alertHelper: AlertHelper
    @EnvironmentObject private var router: MainRouter
    @StateObject var viewModel = IngredientsViewModel()
    @ObservedObject var rowData: MenuRowData

    var body: some View {
        // let _ = Self._printChanges()

        VStack(spacing: 0) {
            List {
                header
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                ForEach(viewModel.listData) { vm in
                    Button {
                        viewModel.select(vm.index)
                    } label: {
                        IngredientsItemRow(data: vm)
                    }
                    .listRowInsets(.init())
                }
            }

            if !viewModel.showCartText.isEmpty {
                footer
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.default, value: viewModel.showCartText.isEmpty)
        .alertModifier(viewModel, alertHelper, router)
        .listStyle(.plain)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .task {
            await viewModel.loadData(rowData: rowData)
        }
    }

    @ViewBuilder
    var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Image(.bgWood)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()

                if let image = rowData.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                } else if rowData.pizza.imageUrl != nil {
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
    var footer: some View {
        Button {
            self.viewModel.addToCart()
        } label: {
            Text(viewModel.showCartText)
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                .foregroundStyle(.price)
                .contentShape(Rectangle())
        }
        .background {
            Color.button
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

private extension View {
    func alertModifier(
        _ viewModel: IngredientsViewModel,
        _ alertHelper: AlertHelper,
        _ router: MainRouter
    ) -> some View {
        onReceive(viewModel.alertKind) { kind in
            switch kind {
            case .added:
                alertHelper.showAlert(
                    isTouchOutside: true,
                    alignment: .top
                ) {
                    CustomNotification(text: .localizable(.addedNotification)) {
                        router.setTo(.cart)
                    }
                    .transition(.move(edge: .top))
                }
            }
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
                            rowData: .preview(from: pizzas, at: 0)
                        )
                    }
                }
                .task {
                    let service = Container.shared.menuUseCase()
                    try? await service.initialize()
                    pizzas = await service.pizzas()
                }
            }
        }
    }

    return AsyncTestView()
        .environmentObject(AlertHelper())
        .environmentObject(MainRouter())
}

#endif
