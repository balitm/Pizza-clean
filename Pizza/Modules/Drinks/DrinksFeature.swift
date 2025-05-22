//
//  DrinksFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct DrinksFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {}

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}