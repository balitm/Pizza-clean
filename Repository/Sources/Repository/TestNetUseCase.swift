//
//  TestNetUseCase.swift
//
//
//  Created by Balázs Kilvády on 4/24/20.
//

import Foundation
import Domain
import DataSource
import Combine

struct TestNetUseCase: NetworkProtocol {
    private func _publish<T: Decodable>(_ data: T) -> AnyPublisher<T, APIError> {
        Result.Publisher(data).eraseToAnyPublisher()
    }

    func getIngredients() -> AnyPublisher<[Ingredient], APIError> {
        _publish(PizzaData.ingredients)
    }

    func getDrinks() -> AnyPublisher<[DataSource.Drink], APIError> {
        _publish(PizzaData.drinks)
    }

    func getPizzas() -> AnyPublisher<DataSource.Pizzas, APIError> {
        _publish(PizzaData.dsPizzas)
    }

    func getImage(url _: URL) -> AnyPublisher<Image, APIError> {
        Empty<Image, APIError>().eraseToAnyPublisher()
    }

    func checkout(cart _: DataSource.Cart) -> AnyPublisher<Void, APIError> {
        Result.Publisher(()).eraseToAnyPublisher()
    }
}
