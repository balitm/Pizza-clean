//
//  ViewModelBase.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 22..
//

import Foundation
import Domain

class ViewModelBase: ObservableObject {
    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    init() {
        DLog(">>> init: ", type(of: self))
    }
}
