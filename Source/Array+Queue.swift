//
//  Array+Queue.swift
//  SwiftGraylog
//
//  Created by Alexandre Karst on 14/11/2018.
//  Copyright © 2018 iAdvize. All rights reserved.
//

import Foundation

/// Enum representing virtual cursors at the beginning and the end of the array.
///
/// - begin: virtual cursor representing the position before the first item of the array.
/// - end: virtual cursor representing the position after the last item of the array.
enum ArrayPosition {
    // [ 1,2,3]
    //  ^
    case begin

    // [1,2,3 ]
    //       ^
    case end
}

extension Array {
    /// Remove and return first X elements.
    ///
    /// - Parameter elementsCount: Number of elements to dequeue.
    /// - Returns: An array which contains all dequeued elements.
    mutating func dequeueFirst(_ elementsCount: Int) -> [Element] {
        let elements = Array(prefix(elementsCount))

        switch count {
        case 0: return []
        case 1: remove(at: 0)
        default: removeSubrange(0...Swift.min(elementsCount - 1, count - 1))
        }

        return elements
    }

    /// Queuing a bunch of elements at the begining or at the end of the array depending
    /// on the `position` parameter.
    ///
    /// - Parameters:
    ///   - elements: Array of elements to insert.
    ///   - position: Position at which we insert the new elements.
    mutating func queue(_ elements: [Element], at position: ArrayPosition) {
        switch position {
        case .begin:
            self = elements + self
        case .end:
            self += elements
        }
    }
}
