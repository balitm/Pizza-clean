//
//  Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/29/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Factory
import Domain
import Repository

let mvm = Container.shared.menuUseCase()
