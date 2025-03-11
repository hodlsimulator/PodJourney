//
//  MemoryTile.swift
//  Alarm Clock
//
//  Created by . . on 06/04/2024.
//

import Foundation
// MemoryTile.swift

import SwiftUI

struct MemoryTile: Identifiable {
    var id = UUID()
    var isRevealed: Bool
    var isCorrect: Bool

    // Other properties...
}

// Manual Equatable conformance
extension MemoryTile: Equatable {
    static func ==(lhs: MemoryTile, rhs: MemoryTile) -> Bool {
        return lhs.id == rhs.id
    }
}
