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

final class ContentViewModel: ViewModelBase {
    enum AlertKind {
        case none, noNetwork
    }

    @Injected(\.reachability) var reachability

    var alertKind: AnyPublisher<AlertKind, Never> { _alertKind.eraseToAnyPublisher() }
    private let _alertKind = PassthroughSubject<AlertKind, Never>()

    func listenToReachabiity() async {
        for await connection in reachability.connection {
            _alertKind.send(connection == .unavailable ? .noNetwork : .none)
        }
    }
}
