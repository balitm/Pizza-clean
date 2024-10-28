//
//  MainRouter.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 20..
//

import SwiftUI
import Domain

enum MainPath: Hashable {
    case cart, drinks, ingredients(Pizza, Binding<Image?>)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .cart, .drinks:
            hasher.combine(self)
        case let .ingredients(pizza, _):
            hasher.combine(pizza)
        }
    }

    static func ==(lhs: MainPath, rhs: MainPath) -> Bool {
        switch (lhs, rhs) {
        case (.cart, .cart), (.drinks, .drinks):
            true
        case let (.ingredients(lhsPizza, _), .ingredients(rhsPizza, _)):
            lhsPizza == rhsPizza
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
        case let .ingredients(pizza, binding):
            IngredientsListView(viewModel: .init(pizza: pizza), image: binding)
        }
    }
}
