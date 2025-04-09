//
//  Injection.swift
//  Repository
//
//  Created by Balázs Kilvády on 2024. 10. 14..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Factory
import Domain

// extension Container {
//     var initActor: Factory<InitRepository> {
//         self { InitRepository() }.singleton
//     }
// }
//
// public extension Container {
//     var reachability: Factory<ReachabilityUseCase> {
//         self { ReachabilityRepository() }
//     }
//
//     var menuUseCase: Factory<MenuUseCase> {
//         self { MenuRepository() }
//     }
//
//     var ingredientsUseCase: Factory<IngredientsUseCase> {
//         self { IngredientsRepository() }
// #if DEBUG
//             .onPreview {
//                 debugPrint(#fileID, #line, "#1 on Preview, switching to preview ingredients repository.")
//                 return PreviewIngredientsRepository()
//             }
// #endif
//     }
//
//     var drinksUseCase: Factory<DrinksUseCase> {
//         self { DrinksRepository() }
// #if DEBUG
//             .onPreview {
//                 debugPrint(#fileID, #line, "#1 on Preview, switching to mock drinks repository.")
//                 return PreviewDrinksRepository()
//             }
// #endif
//     }
//
//     var saveUseCase: Factory<SaveUseCase> {
//         self { SaveRepository() }
//     }
//
//     var cartUseCase: Factory<CartUseCase> {
//         self { CartRepository() }
// #if DEBUG
//             .onPreview {
//                 debugPrint(#fileID, #line, "#1 on Preview, switching to mock cart repository.")
//                 return PreviewCartRepository()
//             }
// #endif
//     }
// }
