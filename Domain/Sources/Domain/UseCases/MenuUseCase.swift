//
//  MenuUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Combine
import struct SwiftUI.Image

public protocol MenuUseCase {
    /// Initialize components.
    func initialize() async throws

    /// DataSource of available pizzas.
    func pizzas() async -> Pizzas

    /// Add a pizza to the shopping cart.
    func addToCart(pizza: Pizza) async

    /// Download an image for a pizza.
    /// - Parameter pizza: The pizza.
    /// - Returns: SwiftUI.Image.
    func dowloadImage(for pizza: Pizza) async throws -> Image?

    /// Version info string to show.
    var appVersionInfo: String { get }
}
