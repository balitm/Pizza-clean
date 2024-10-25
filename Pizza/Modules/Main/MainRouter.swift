//
//  MainRouter.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 20..
//

import SwiftUI

enum MainPath: Hashable {
    case cart, drinks
}

final class MainRouter: CustomNavPathProvider<MainPath>, Routing {
    @ViewBuilder func view(for route: MainPath) -> some View {
        switch route {
        case .cart:
            CartView()
        case .drinks:
            DrinksListView()
        }
    }
}
