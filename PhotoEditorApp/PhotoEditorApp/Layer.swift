//
//  Layer.swift
//  PhotoEditorApp
//
//  Created by . . on 23/09/2024.
//

import Cocoa

// Layer class to manage individual layers in the app
class Layer {
    var image: NSImage
    var opacity: CGFloat
    var isVisible: Bool

    init(image: NSImage, opacity: CGFloat = 1.0, isVisible: Bool = true) {
        self.image = image
        self.opacity = opacity
        self.isVisible = isVisible
    }
}
