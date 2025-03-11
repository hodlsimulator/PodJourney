//
//  AppDelegate.swift
//  PhotoEditorApp
//
//  Created by . . on 23/09/2024.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
            NSApp.appearance = NSAppearance(named: .darkAqua)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

