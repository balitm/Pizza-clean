import Testing
import Foundation
import Factory
import class UIKit.UIImage
@testable import DataSource

struct DataSourceTests {
    @Test func network() async throws {
        let drinksCase = PizzaReqests.getDrinks
        let api = API()
        let drinks: [DS.Drink] = try! await api.perform(request: drinksCase)
        debugPrint(#fileID, #line, drinks)
        #expect(!drinks.isEmpty)

        let ingredients: [DS.Ingredient] = try! await api.perform(request: PizzaReqests.getIngredients)
        debugPrint(#fileID, #line, ingredients)
        #expect(!ingredients.isEmpty)

        let pizzas: DS.Pizzas = try! await api.perform(request: PizzaReqests.getPizzas)
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)

        if let str = pizzas.pizzas[2].imageUrl, let url = URL(string: str) {
            let data = try! await api.perform(request: PizzaReqests.downloadImage(url: url))
            debugPrint(#fileID, #line, "recved data: \(data.count)")
            let image = UIImage(data: data)
            debugPrint(#fileID, #line, "imge size:", image?.size ?? .zero)
        }

        try! await api.perform(request: PizzaReqests.checkout(pizzas: [pizzas.pizzas[0]], drinks: [drinks[0].id]))
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)
    }

    @Test func appVersion() async throws {
        let appConfig = DataSourceContainer.shared.appConfig()
        #expect(appConfig.pizzaBaseURL == "http://localhost:4010")
    }

    @Test func publicAPI() async throws {
        let api = APIPizzaNetwork()
        await testNetwork(api: api)
    }

    @Test func mockAPI() async throws {
        let api = Container.shared.pizzaAPI()
        await testNetwork(api: api)
    }

    func testNetwork(api: PizzaNetwork) async {
        let drinks = try! await api.getDrinks()
        debugPrint(#fileID, #line, drinks)
        #expect(!drinks.isEmpty)

        let ingredients = try! await api.getIngredients()
        debugPrint(#fileID, #line, ingredients)
        #expect(!ingredients.isEmpty)

        let pizzas = try! await api.getPizzas()
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)

        if let str = pizzas.pizzas[2].imageUrl, let url = URL(string: str) {
            let cgImage = try! await api.downloadImage(url: url)
            debugPrint(#fileID, #line, "image size:", cgImage.height, cgImage.width)
        }

        try! await api.checkout(pizzas: [pizzas.pizzas[0]], drinks: [drinks[0].id])
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)
    }
}
