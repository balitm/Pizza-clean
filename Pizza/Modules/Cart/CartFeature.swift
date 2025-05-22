//
//  CartFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct CartFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {
        case delegate(Delegate)

        enum Delegate: Equatable {
            case dismiss
        }
    }

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}