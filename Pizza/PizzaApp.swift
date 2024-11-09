//
//  PizzaApp.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 04..
//  Copyright © 2024 kil-dev. All rights reserved.
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
                // .tint(.accent)
                .environmentObject(AlertHelper())
        }
    }

    private func configNavBar() {
        // Using UIColor.accent breaks the global accent color in SwiftUI
        var aColor: UIColor {
            UIColor { traits -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                    UIColor(red: 0.812, green: 0.322, blue: 0.294, alpha: 1) :
                    UIColor(red: 0.882, green: 0.302, blue: 0.271, alpha: 1)
            }
        }
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: aColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: aColor]
    }
}
