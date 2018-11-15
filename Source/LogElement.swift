//
//  LogElement.swift
//  SwiftGraylog
//
//  Created by Alexandre Karst on 14/11/2018.
//  Copyright © 2018 iAdvize. All rights reserved.
//

import Foundation

public typealias LogValues = [AnyHashable: Any]

class LogElement: Equatable {
    let values: LogValues

    init(values: LogValues) {
        self.values = values
    }

    static func == (rhs: LogElement, lhs: LogElement) -> Bool {
        return rhs === lhs
    }
}
