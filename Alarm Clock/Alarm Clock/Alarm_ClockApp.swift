//
//  Alarm_ClockApp.swift
//  Alarm Clock
//
//  Created by . . on 05/04/2024.
//

import SwiftUI
import AppKit

@main
struct Alarm_ClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty or minimal scene setup
        // You can provide settings or handle non-window-related app functionality here
        Settings {
            Text("Settings Placeholder") // This is just a placeholder
        }
    }
}
