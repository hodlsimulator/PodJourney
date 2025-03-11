//
//  CanvasView.swift
//  PhotoEditorApp
//
//  Created by . . on 23/09/2024.
//

import Cocoa

class CanvasView: NSView {
    var image: NSImage?  // The composited image to display

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        image?.draw(in: bounds)  // Draw the image to fill the entire view
    }
}
