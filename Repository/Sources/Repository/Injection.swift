//
//  Injection.swift
//  Repository
//
//  Created by Balázs Kilvády on 2024. 10. 14..
//

import Foundation
import Factory
import Domain

extension Container {
    var initActor: Factory<InitRepository> {
        self { InitRepository() }.singleton
    }
}

public extension Container {
    var menuUseCase: Factory<MenuUseCase> {
        self { MenuRepository() }
    }

    var ingredientsUseCase: Factory<IngredientsUseCase> {
        self { IngredientsRepository() }
    }

    var drinksUseCase: Factory<DrinksUseCase> {
        self { DrinksRepository() }
    }

    var saveUseCase: Factory<SaveUseCase> {
        self { SaveRepository() }
    }

    var cartUseCase: Factory<CartUseCase> {
        self { CartRepository() }
    }
}
