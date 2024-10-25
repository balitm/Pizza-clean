//
//  DrinksUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation

public protocol DrinksUseCase {
    func drinks() async -> [Drink]
    func addToCart(drinkIndex: Int) async
}
