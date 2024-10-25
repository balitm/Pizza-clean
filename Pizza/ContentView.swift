//
//  ContentView.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 04..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AlertHelperView {
            MenuListView()
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
