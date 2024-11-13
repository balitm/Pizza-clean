//
//  IngredientsHeaderRowData.swift
//  Pizza
//
//  Created by Balázs Kilvády on 6/21/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import struct SwiftUI.Image
import class UIKit.UIImage

struct IngredientsHeaderRowData {
    let image: Image?

    init(image: UIImage?) {
        self.image = image.map { Image(uiImage: $0) }
    }
}
