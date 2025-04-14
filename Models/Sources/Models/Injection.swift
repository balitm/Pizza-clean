//
//  Injection.swift
//  Repository
//
//  Created by Balázs Kilvády on 2024. 10. 14..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Factory
import Domain

public extension Container {
    var cartModel: Factory<Domain.CartModel> {
        self { CartModel() }.singleton
    }

    var componentsModel: Factory<Domain.ComponentsModel> {
        self { ComponentsModel() }.singleton
    }

    var ingredientsModel: Factory<Domain.IngredientsModel> {
        self { IngredientsModel() }.singleton
    }

    var menuModel: Factory<Domain.MenuModel> {
        self { MenuModel() }.singleton
    }

    var reachability: Factory<Domain.ReachabilityModel> {
        self { ReachabilityModel() }
    }
}
