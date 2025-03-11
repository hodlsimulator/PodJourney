//
//  NSImage+Extensions.swift
//  PhotoEditorApp
//
//  Created by . . on 23/09/2024.
//

import Foundation
import Cocoa

// Extension to resize NSImage
extension NSImage {
    func resize(to newSize: NSSize) -> NSImage {
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        let context = NSGraphicsContext.current
        context?.imageInterpolation = .high
        self.draw(in: NSRect(origin: .zero, size: newSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
