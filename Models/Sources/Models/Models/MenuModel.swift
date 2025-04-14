//
//  MenuModel.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 11..
//

import Foundation
import Domain
import DataSource
import Factory
import struct SwiftUI.Image

final class MenuModel: Domain.MenuModel {
    @Injected(\.cartModel) private var cartModel
    @Injected(\.componentsModel) private var component
    @Injected(\DataSourceContainer.pizzaAPI) var network
    @Injected(\DataSourceContainer.appConfig) var appConfig

    func initialize() async throws {
        try? await withThrowingDiscardingTaskGroup { group in
            group.addTask(operation: component.initialize)
            group.addTask { [cartModel] in try await cartModel.initialize() }
        }
    }

    func pizzas() async -> Pizzas {
        await component.pizzas
    }

    func addToCart(pizza: Pizza) async {
        await cartModel.add(pizza: pizza)
    }

    func dowloadImage(for pizza: Pizza) async throws -> Image? {
        guard let url = pizza.imageUrl else { return nil }
        let cgImage = try await network.downloadImage(url: url)
        return Image(decorative: cgImage, scale: 1)
    }

    var appVersionInfo: String {
        "\(String(models: .appVersion)): \(appConfig.appVersion) - \(appConfig.appBuild)"
    }
}
