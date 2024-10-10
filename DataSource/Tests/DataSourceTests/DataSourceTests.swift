import Testing
import Foundation
import class UIKit.UIImage
@testable import DataSource

struct DataSourceTests {
    @Test func networkGet() async throws {
        let drinksCase = PizzaReqests.getDrinks
        let drinks: [DS.Drink] = try! await API.shared.perform(request: drinksCase)
        debugPrint(#fileID, #line, drinks)
        #expect(!drinks.isEmpty)

        let ingredients: [DS.Ingredient] = try! await API.shared.perform(request: PizzaReqests.getIngredients)
        debugPrint(#fileID, #line, ingredients)
        #expect(!ingredients.isEmpty)

        let pizzas: DS.Pizzas = try! await API.shared.perform(request: PizzaReqests.getPizzas)
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)

        if let str = pizzas.pizzas[2].imageUrl, let url = URL(string: str) {
            let data = try! await API.shared.perform(request: PizzaReqests.downloadImage(url: url))
            debugPrint(#fileID, #line, "recved data: \(data.count)")
            let image = UIImage(data: data)
            debugPrint(#fileID, #line, "imge size:", image?.size ?? .zero)
        }

        try! await API.shared.perform(request: PizzaReqests.checkout(pizzas: [pizzas.pizzas[0]], drinks: [drinks[0].id]))
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)
    }
}
