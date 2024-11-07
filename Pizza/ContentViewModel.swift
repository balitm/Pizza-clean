//
//  ContentViewModel.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 31..
//
import Foundation
import Domain
import Factory
import Combine

@MainActor
final class ContentViewModel: ViewModelBase {
    enum AlertKind {
        case none, noNetwork
    }

    @Injected(\.reachability) var reachability

    let menuListViewModel = MenuListViewModel()
    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()

    func listenToReachabity() async {
        for await connection in reachability.connection {
            switch connection {
            case .wifi, .cellular:
                menuListViewModel.resume()
                _alertKind.send(.none)
            case .unavailable:
                menuListViewModel.reset()
                _alertKind.send(.noNetwork)
            }
        }
        DLog(l: .trace, "Reachabilty for await ended.")
    }
}
