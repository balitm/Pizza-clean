//
//  DatabaseContainerProtocol.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/24/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

protocol DatabaseContainerProtocol {}

extension DatabaseContainerProtocol {
    static func initContainer() -> Container? {
        dbQueue.sync {
            do {
                return try Container()
            } catch {
                DLog("# DB init failed: ", error)
            }
            return nil
        }
    }
}
