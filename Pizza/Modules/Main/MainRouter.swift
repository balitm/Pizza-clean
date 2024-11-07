//
//  MainRouter.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 20..
//

import SwiftUI
import Domain

enum MainPath: Hashable {
    case cart, drinks, ingredients(MenuRowData)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .cart, .drinks:
            hasher.combine(self)
        case let .ingredients(rowData):
            hasher.combine(rowData.pizza)
        }
    }

    static func ==(lhs: MainPath, rhs: MainPath) -> Bool {
        switch (lhs, rhs) {
        case (.cart, .cart), (.drinks, .drinks):
            true
        case let (.ingredients(lhs), .ingredients(rhs)):
            lhs.pizza == rhs.pizza
        default:
            false
        }
    }
}

final class MainRouter: CustomNavPathProvider<MainPath>, Routing {
    @ViewBuilder func view(for route: MainPath) -> some View {
        switch route {
        case .cart:
            CartView()
        case .drinks:
            DrinksListView()
        case let .ingredients(rowData):
            IngredientsListView(rowData: rowData)
        }
    }
}
