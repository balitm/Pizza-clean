//
//  DrinksUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public protocol DrinksUseCase {
    func drinks() async -> [Drink]
    func addToCart(drinkIndex: Int) async
}
