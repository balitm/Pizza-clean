//
//  NetworkRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine
import Domain
import DataSource
import Factory
import class UIKit.UIImage

public typealias Image = UIImage

protocol NetworkProtocol {
    func getPizzas() -> AnyPublisher<DataSource.Pizzas, APIError>
    func getIngredients() -> AnyPublisher<[DataSource.Ingredient], APIError>
    func getDrinks() -> AnyPublisher<[DataSource.Drink], APIError>
    func getImage(url: URL) -> AnyPublisher<Image, APIError>
    func checkout(cart: DataSource.Cart) -> AnyPublisher<Void, APIError>
}

enum RAPI {}

extension RAPI {
    struct Network: NetworkProtocol {
        let api = Container.shared.mockPizzaAPI()

        func getPizzas() -> AnyPublisher<DataSource.Pizzas, APIError> {
            let subject = UncheckedSendable(PassthroughSubject<DataSource.Pizzas, APIError>())
            Task {
                let data = try await self.api.getPizzas()
                subject.unwrap.send(data)
            }
            return subject.unwrap.eraseToAnyPublisher()
        }

        func getIngredients() -> AnyPublisher<[DataSource.Ingredient], APIError> {
            let subject = UncheckedSendable(PassthroughSubject<[DataSource.Ingredient], APIError>())
            Task {
                let data = try await self.api.getIngredients()
                subject.unwrap.send(data)
            }
            return subject.unwrap.eraseToAnyPublisher()
        }

        func getDrinks() -> AnyPublisher<[DataSource.Drink], APIError> {
            let subject = UncheckedSendable(PassthroughSubject<[DataSource.Drink], APIError>())
            Task {
                let data = try await self.api.getDrinks()
                subject.unwrap.send(data)
            }
            return subject.unwrap.eraseToAnyPublisher()
        }

        func getImage(url: URL) -> AnyPublisher<Image, APIError> {
            let subject = UncheckedSendable(PassthroughSubject<Image, APIError>())
            Task {
                let data = try await self.api.downloadImage(url: url)
                subject.unwrap.send(data)
            }
            return subject.unwrap.eraseToAnyPublisher()
        }

        func checkout(cart: DataSource.Cart) -> AnyPublisher<Void, APIError> {
            let subject = UncheckedSendable(PassthroughSubject<Void, APIError>())
            Task {
                try await self.api.checkout(pizzas: cart.pizzas, drinks: cart.drinks)
                subject.unwrap.send(())
            }
            return subject.unwrap.eraseToAnyPublisher()
        }
    }
}

struct UncheckedSendable<T>: @unchecked Sendable {
    let unwrap: T
    init(_ value: T) { unwrap = value }
}
