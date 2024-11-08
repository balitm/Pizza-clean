//
//  MenuRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import Domain
import DataSource
import Factory
import struct SwiftUI.Image

final class MenuRepository: MenuUseCase {
    @Injected(\.initActor) private var initActor
    @Injected(\DataSourceContainer.pizzaAPI) var network
    @Injected(\DataSourceContainer.appConfig) var appConfig

    func initialize() async throws {
        _ = try await initActor.initialize()
    }

    func pizzas() async -> Pizzas {
        await initActor.component.pizzas
    }

    func addToCart(pizza: Pizza) async {
        _ = await initActor.cartHandler.add(pizza: pizza)
    }

    func dowloadImage(for pizza: Pizza) async throws -> Image? {
        guard let url = pizza.imageUrl else { return nil }
        let cgImage = try await network.downloadImage(url: url)
        return Image(decorative: cgImage, scale: 1)
    }

    var appVersionInfo: String {
        "\(String(repository: .appVersion)): \(appConfig.appVersion) - \(appConfig.appBuild)"
    }
}
