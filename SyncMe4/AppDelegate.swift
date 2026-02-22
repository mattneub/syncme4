//
//  AppDelegate.swift
//  SyncMe4
//
//  Created by Matt Neuburg on 2/21/26.
//

import Cocoa
import SwiftAutomation
import MacOSGlues



@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        do {
            try TextEdit().activate()
            print("ok")
            let result = try TextEdit().name.get()
            print("ok", result)
        } catch {
            print("error", error)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

