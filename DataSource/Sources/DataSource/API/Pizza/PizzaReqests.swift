//
//  PizzaReqests.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 09..
//

import Foundation

private let _kBaseUrl = URL(string: "http://192.168.1.20:4010")!

// final class APINetwork: Sendable {
//     let api = API()
//
//     /// Singleton instance
//     static let shared = APINetwork()
//
//     func getIngredients() -> AnyPublisher<[DS.Ingredient], API.ErrorType> {
//         let url = api.createGetURL("5e91eda1172eb64389622c7a")
//         return api.fetch(url)
//     }
//
//     func getDrinks() -> AnyPublisher<[DS.Drink], API.ErrorType> {
//         let url = api.createGetURL("5e91ef298e85c84370147b21")
//         return api.fetch(url)
//     }
//
//     func getPizzas() -> AnyPublisher<DS.Pizzas, API.ErrorType> {
//         let url = api.createGetURL("5e91f1a0cc62be4369c2e408")
//         return api.fetch(url)
//     }
//
//     func checkout(pizzas: [DS.Pizza], drinks: [DS.Drink.ID]) -> AnyPublisher<Void, API.ErrorType> {
//         let url = api.createPostURL(Checkout(pizzas: pizzas, drinks: drinks))
//         return api.post(url)
//     }
//
//     func downloadImage(url: URL) -> AnyPublisher<Image, API.ErrorType> {
//         URLSession.shared.dataTaskPublisher(for: url)
//             .tryMap {
//                 guard let image = Image(data: $0.data) else {
//                     throw API.ErrorType.processingFailed
//                 }
//                 return image
//             }
//             .mapError { _ in API.ErrorType.processingFailed }
//             .eraseToAnyPublisher()
//     }
// }

enum PizzaReqests {
    case getIngredients
    case getDrinks
    case getPizzas
    case checkout(pizzas: [DS.Pizza], drinks: [DS.Drink.ID])
    case downloadImage(url: URL)
}

extension PizzaReqests: TargetType {
    var baseURL: URL { _kBaseUrl }

    var path: String {
        switch self {
        case .getIngredients: "ingredients"
        case .getDrinks: "drinks"
        case .getPizzas: "pizzas"
        case .checkout: "checkout"
        case .downloadImage: ""
        }
    }

    var method: Method {
        switch self {
        case .getIngredients, .getDrinks, .getPizzas: .get
        case .checkout: .post
        case .downloadImage: .get
        }
    }

    var isAbsolutePath: Bool {
        switch self {
        case .getIngredients, .getDrinks, .getPizzas, .checkout:
            false
        case .downloadImage:
            true
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
        switch self {
        case .checkout:
            ["Content-type": "application/json"]
        case .getDrinks, .getIngredients, .getPizzas:
            ["Accept": "application/json"]
        case .downloadImage:
            nil
        }
    }

    var timeout: TimeInterval { 30 }

    var retryCount: Int { 2 }
}
