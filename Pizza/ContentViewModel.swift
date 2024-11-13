//
//  ContentViewModel.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 31..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Factory
import Combine

@MainActor
@Observable final class ContentViewModel: ViewModelBase {
    enum AlertKind {
        case none, noNetwork
    }

    @ObservationIgnored @Injected(\.reachability) var reachability

    let menuListViewModel = MenuListViewModel()
    @ObservationIgnored var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.removeDuplicates().eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()
    private var hasNetwork = true

    func listenToReachabity() async {
        for await connection in reachability.connection {
            switch connection {
            case .wifi, .cellular:
                if !hasNetwork {
                    hasNetwork = true
                    menuListViewModel.resume()
                    _alertKind.send(.none)
                }
            case .unavailable:
                if hasNetwork {
                    hasNetwork = false
                    menuListViewModel.reset()
                    await reachability.resetSession()
                    _alertKind.send(.noNetwork)
                }
            }
        }
        DLog(l: .trace, "Reachabilty for await ended.")
    }
}
