import Foundation
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    let alarmManager = AlarmManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the window with the specified style
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.delegate = self  // Set this AppDelegate as the window's delegate
        window.makeKeyAndOrderFront(nil)

        // Set the content view of the window
        let contentView = ContentView(alarmManager: self.alarmManager)
        window.contentView = NSHostingView(rootView: contentView)
    }
    
    // Called when the window's size changes
    @objc func windowDidResize(_ notification: Notification) {
        print("Window did resize to: \(window.frame.size)")
    }

    // NSWindowDelegate method that is called just before the window closes
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self) // Terminate the application
    }
}
