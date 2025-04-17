//
//  MenuModel.swift
//  Domain
//
//  Created by Balázs Kilvády on 2025. 04. 11..
//

import struct SwiftUI.Image

public protocol MenuModel: Actor {
    func initialize() async throws
    func pizzas() async -> Pizzas
    func addToCart(pizza: Pizza) async
    func dowloadImage(for pizza: Pizza) async throws -> Image?
    nonisolated func appVersionInfo() -> String
}
