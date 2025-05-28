//
//  MenuRowFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import ComposableArchitecture

@Reducer
struct MenuRowFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        var data: MenuRowData
        var id: Int { data.index }
    }

    enum Action {
        case onTapDetails
        case onTapAddToCart
        case downloadImage
        case imageResponse(Image?)
        case delegate(Delegate)

        enum Delegate {
            case showDetails(MenuRowData)
            case addToCart(Int)
        }
    }

    @Dependency(\.menuModel) private var menuModel

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onTapDetails:
                return .send(.delegate(.showDetails(state.data)))

            case .onTapAddToCart:
                return .send(.delegate(.addToCart(state.data.index)))

            case .downloadImage:
                guard state.data.image == nil else { return .none }
                return .run { [pizza = state.data.pizza] send in
                    do {
                        let image = try await menuModel.dowloadImage(for: pizza)
                        DLog(l: .trace, "#> image downloaded for \(pizza.name)")
                        await send(.imageResponse(image))
                    } catch {
                        DLog(l: .trace, "#> image download for \(pizza.name) failed: \(error)")
                        await send(.imageResponse(nil))
                    }
                }

            case let .imageResponse(image):
                state.data.image = image
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
