//
//  PizzaApp.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 04..
//

import SwiftUI

@main
struct PizzaApp: App {
    init() {
        configNavBar()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AlertHelper())
        }
    }

    private func configNavBar() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.tint]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.tint]
    }
}
