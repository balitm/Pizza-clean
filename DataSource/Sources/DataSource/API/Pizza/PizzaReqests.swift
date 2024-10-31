//
//  PizzaReqests.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 09..
//

import Foundation
import Domain
import Factory
import CoreGraphics
import ImageIO

/// Protocol for request Pizza API.
public protocol PizzaNetwork: Sendable {
    func getIngredients() async throws -> [DataSource.Ingredient]
    func getDrinks() async throws -> [DataSource.Drink]
    func getPizzas() async throws -> DataSource.Pizzas
    func checkout(pizzas: [DataSource.Pizza], drinks: [DataSource.Drink.ID]) async throws
    func checkout(cart: DataSource.Cart) async throws
    func downloadImage(url: URL) async throws -> CGImage
}

public extension PizzaNetwork {
    func checkout(cart: DataSource.Cart) async throws {
        try await checkout(pizzas: cart.pizzas, drinks: cart.drinks)
    }
}

/// Implementation of request Pizza API.
final class APIPizzaNetwork: PizzaNetwork {
    let api = API()

    /// Singleton instance
    static let shared = APIPizzaNetwork()

    func getIngredients() async throws -> [DataSource.Ingredient] {
        try await api.perform(request: PizzaReqests.getIngredients)
    }

    func getDrinks() async throws -> [DataSource.Drink] {
        try await api.perform(request: PizzaReqests.getDrinks)
    }

    func getPizzas() async throws -> DataSource.Pizzas {
        try await api.perform(request: PizzaReqests.getPizzas)
    }

    func checkout(pizzas: [DS.Pizza], drinks: [DS.Drink.ID]) async throws {
        try await api.perform(request: PizzaReqests.checkout(pizzas: pizzas, drinks: drinks))
    }

    func downloadImage(url: URL) async throws -> CGImage {
        let data = try await api.perform(request: PizzaReqests.downloadImage(url: url))
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { throw APIError(kind: .processingFailed) }
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        guard let image else { throw APIError(kind: .processingFailed) }
        return image
    }
}

#if DEBUG
/// Mock implementation of request Pizza API.
public final class MockPizzaNetwork: PizzaNetwork {
    public init() {}

    public func getIngredients() async throws -> [DataSource.Ingredient] {
        PizzaData.ingredients
    }

    public func getDrinks() async throws -> [DataSource.Drink] {
        PizzaData.drinks
    }

    public func getPizzas() async throws -> DataSource.Pizzas {
        PizzaData.pizzas
    }

    public func checkout(pizzas _: [DataSource.Pizza], drinks _: [DataSource.Drink.ID]) async throws {}

    public func downloadImage(url: URL) async throws -> CGImage {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { throw APIError(kind: .processingFailed) }
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        guard let image else { throw APIError(kind: .processingFailed) }
        return image
    }
}
#endif

/// Request declarations of Pizza API.
enum PizzaReqests {
    case getIngredients
    case getDrinks
    case getPizzas
    case checkout(pizzas: [DS.Pizza], drinks: [DS.Drink.ID])
    case downloadImage(url: URL)
}

/// Request definitions of Pizza API
extension PizzaReqests: TargetType {
    var baseURL: URL {
        switch self {
        case let .downloadImage(url):
            return url
        default:
            let string = DataSourceContainer.shared.appConfig().pizzaBaseURL
            return URL(string: string)!
        }
    }

    var path: String? {
        switch self {
        case .getIngredients: "ingredients"
        case .getDrinks: "drinks"
        case .getPizzas: "pizzas"
        case .checkout: "checkout"
        case .downloadImage: nil
        }
    }

    var method: Method {
        switch self {
        case .getIngredients, .getDrinks, .getPizzas: .get
        case .checkout: .post
        case .downloadImage: .get
        }
    }

    var requestParameters: RequestParameters {
        switch self {
        case let .checkout(pizzas, drinks):
            let object = CheckoutRequest(pizzas: pizzas, drinks: drinks)
            return .requestJSONEncodable(object)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers: [String: String]? = switch self {
        case .checkout:
            ["Content-type": "application/json"]
        case .getDrinks, .getIngredients, .getPizzas:
            ["Accept": "application/json"]
        case .downloadImage:
            nil
        }

        headers?.merge(["Authorization": "Bearer \(_kFallbackToken)"], uniquingKeysWith: { $1 })
        return headers
    }

    var timeout: TimeInterval { 30 }

    var retryCount: Int { 2 }
}

private let _kFallbackToken =
    """
    eyJ0eXAiOiJKV1QiLCJraWQiOiJpV3FKSTY3dUttVkpBQWdraEdSQW9NVGtObVk9IiwiYWxnIjoiUlMyNTYifQ
    """
