//
//  Network.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 09..
//

import Foundation

private let _kBaseUrl = URL(string: "http://192.168.1.20:4010")!

enum Network {
    case getIngredients
    case getDrinks
    case getPizzas
    case checkout(pizzas: [DS.Pizza], drinks: [DS.Drink.ID])
    case downloadImage(url: URL)
}

extension Network: TargetType {
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

    var resultIsData: Bool {
        switch self {
        case .getIngredients, .getDrinks, .getPizzas:
            false
        case .checkout, .downloadImage:
            true
        }
    }

    var decodableResutType: (any Decodable.Type)? {
        switch self {
        case .getIngredients:
            [DS.Ingredient].self
        case .getDrinks:
            [DS.Drink].self
        case .getPizzas:
            DS.Pizzas.self
        case .checkout:
            nil
        case .downloadImage:
            nil
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
        default:
            .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }

    var timeout: TimeInterval { 30 }

    var retryCount: Int { 2 }
}
