//
//  MenuRow.swift
//  Pizza
//
//  Created by Balázs Kilvády on 6/8/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct MenuRow: View {
    @Environment(MainRouter.self) private var router
    var data: MenuRowData

    var body: some View {
        Button {
            router.push(.ingredients(data))
        } label: {
            rowView
        }
        .onAppear {
            data.downloadImage()
        }
    }

    var rowView: some View {
        ZStack(alignment: .top) {
            Image(.bgWood)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 128, alignment: .top)
                .clipped()

            if let image = data.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 179)
                    .clipped()
            } else if data.pizza.imageUrl != nil {
                ProgressView()
                    .tint(.gray)
                    .frame(height: 128)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(data.pizza.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(data.ingredientsText)
                        .font(.system(size: 14))
                        .foregroundStyle(.text)
                }
                Button {
                    data.addToCart()
                } label: {
                    HStack(spacing: 4) {
                        Image(.icCartButton)
                            .resizable()
                            .foregroundStyle(.price)
                            .frame(width: 14, height: 14)
                            .scaledToFit()
                        Text(data.priceText)
                            .foregroundStyle(.price)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(width: 64, height: 28)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.button)
                    )
                }
            }
            .padding()
            .background(.regularMaterial, in: Rectangle())
            .padding(.top, 109)
        }
    }
}

#if DEBUG
import Factory

#Preview {
    struct AsyncTestView: View {
        @State var pizzas: Pizzas?

        var body: some View {
            VStack(spacing: 10) {
                if let pizzas {
                    MenuRow(data: .preview(from: pizzas, at: 0))
                    MenuRow(data: .preview(from: pizzas, at: 1))
                        .environment(\.colorScheme, .dark)
                }
            }
            .task {
                let component = Container.shared.componentsModel()
                try? await component.initialize()
                pizzas = await component.pizzas
            }
        }
    }

    return AsyncTestView()
        .environment(MainRouter())
}
#endif
