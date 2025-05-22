//
//  IngredientsFeature.swift
//  Pizza
//
//  Created by Alex Carmack on 2024.02.23.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
struct IngredientsFeature {
    @ObservableState
    struct State: Equatable {
        var pizzaData: MenuRowData? = nil
    }

    enum Action: Equatable {}

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}