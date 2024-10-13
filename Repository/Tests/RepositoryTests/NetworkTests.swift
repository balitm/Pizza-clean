//
//  NetworkTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/20/20.
//

import XCTest
import Combine
import Domain
@testable import Repository

class NetworkTests: UseCaseTestsBase {
    func testDrinks() {
        let service = RepositoryUseCaseProvider(container: container,
                                                network: RAPI.Network()).makeDrinksService()
        var cancellable: AnyCancellable?

        expectation(timeout: 5.0) { expectation in
            cancellable = service.drinks()
                .sink(receiveCompletion: {
                    DLog("completed with ", $0)
                }, receiveValue: {
                    DLog("recved ", $0.count)
                    if !$0.isEmpty {
                        expectation.fulfill()
                    }
                })
        }

        cancellable?.cancel()
    }
}
