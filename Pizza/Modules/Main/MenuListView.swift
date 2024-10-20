//
//  MenuListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/9/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct MenuListView: View {
    @EnvironmentObject private var alertHelper: AlertHelper
    @StateObject private var viewModel = MenuListViewModel()

    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.accent]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.accent]
    }

    var body: some View {
        NavigationStack {
            List(viewModel.listData) { rowVM in
                MenuRow(viewModel: rowVM)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
            }
            // NavigationLink(destination:
            //     self.resolver.resolve(
            //         IngredientsListView.self,
            //         args: self._viewModel.pizza(at: vm.index)
            //     )
            // ) {
            //     EmptyView()
            // }
            // .buttonStyle(PlainButtonStyle())
            .listStyle(.plain)
            .navigationTitle(Text("NENNO'S PIZZA"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(.icCartNavbar)
                    // HStack {
                    //     Text("")
                    //     NavigationLink(
                    //         destination:
                    //         resolver.resolve(CartListView.self)
                    //     ) {
                    //         Image("ic_cart_navbar")
                    //     }
                    // }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "plus")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)

                    // HStack {
                    //     Text("")
                    //     NavigationLink(destination:
                    //         resolver.resolve(IngredientsListView.self,
                    //                          args: Just(Pizza()).eraseToAnyPublisher())
                    //     ) {
                    //         Image(systemName: "plus")
                    //             .accentColor(KColors.cTint)
                    //     }
                    // }
                }
            }
            // .sheet(isPresented: $_viewModel.showAdded) {
            //     AddedView()
            // }
        }
        .alertModifier(viewModel, alertHelper)
        .task {
            try? await viewModel.loadPizzas()
        }
    }
}

private extension View {
    func alertModifier(_ viewModel: MenuListViewModel,
                       _ alertHelper: AlertHelper) -> some View {
        onReceive(viewModel.alertKind) { kind in
            switch kind {
            case .none:
                alertHelper.hideAlert()
            case .progress:
                alertHelper.showProgress()
            case .added:
                alertHelper.showAlert(
                    isTouchOutside: true,
                    alignment: .top
                ) {
                    AddNotification()
                        .transition(.move(edge: .top))
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    MenuListView()
        .environmentObject(AlertHelper())
}
#endif
