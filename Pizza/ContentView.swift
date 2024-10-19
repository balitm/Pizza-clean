//
//  ContentView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 04..
//

import SwiftUI
import DataSource
import Factory

struct ContentView: View {
    var body: some View {
        VStack {
            MenuListView()
            // Image(systemName: "globe")
            //     .imageScale(.large)
            //     .foregroundStyle(Color.tint)
            // Text("Hello, world!")
        }
        .padding()
        .task {
            // let api = Container.shared.pizzaAPI()
            // let drinks = try! await api.getDrinks()
            // debugPrint(#fileID, #line, drinks)
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
