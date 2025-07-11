//
//  AsyncTestView+Preview.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 24..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import Factory

// func asyncTest<O>(
//     @ViewBuilder view: @escaping (O) -> some View,
//     task: @escaping () async throws -> O
// ) -> some View {
//     debugPrint(#fileID, #line, "call async test")
//     return AsyncTestView(view: view, task: task)
// }
//
// func asyncPizzasTest(@ViewBuilder view: @escaping (Pizzas) -> some View) -> some View {
//     debugPrint(#fileID, #line, "call async pizzas test")
//     return AsyncTestView(view: view, task: initPizzas)
// }

// struct AsyncTestView<O, V: View>: View {
//     @State var object: O?
//     @ViewBuilder var view: (O) -> V
//     var task: () async throws -> O
//
//     var body: some View {
//         debugPrint(#fileID, #line, "draw async test, object is nil:", object == nil)
//
//         return    Group {
//             if let object {
//                 view(object)
//             }
//         }
//         .task {
//             debugPrint(#fileID, #line, "call async task")
//             object = try? await task()
//         }
//     }
// }

func initPizzas() async throws -> Pizzas {
    let model = Container.shared.componentsModel()
    try? await model.initialize()
    await debugPrint(#fileID, #line, "async pizzas task:", model.pizzas.pizzas.count)
    return await model.pizzas
}
