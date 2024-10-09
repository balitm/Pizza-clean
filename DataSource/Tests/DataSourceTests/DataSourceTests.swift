import XCTest
@testable import DataSource

final class DataSourceTests: XCTestCase {
    // XCTest Documentation
    // https://developer.apple.com/documentation/xctest

    // Defining Test Cases and Test Methods
    // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

    func testNetworkGet() async throws {
        let drinksCase = PizzaReqests.getDrinks
        let drinks: [DS.Drink] = try! await API.shared.perform(request: drinksCase)
        debugPrint(#fileID, #line, drinks)
        XCTAssertTrue(!drinks.isEmpty)

        let ingredients: [DS.Ingredient] = try! await API.shared.perform(request: PizzaReqests.getIngredients)
        debugPrint(#fileID, #line, ingredients)
        XCTAssertTrue(!ingredients.isEmpty)

        let pizzas: DS.Pizzas = try! await API.shared.perform(request: PizzaReqests.getPizzas)
        debugPrint(#fileID, #line, pizzas)
        XCTAssertTrue(!pizzas.pizzas.isEmpty)

        try! await API.shared.perform(request: PizzaReqests.checkout(pizzas: [pizzas.pizzas[0]], drinks: [drinks[0].id]))
        debugPrint(#fileID, #line, pizzas)
        XCTAssertTrue(!pizzas.pizzas.isEmpty)
    }
}
