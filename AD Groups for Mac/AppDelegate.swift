//
//  AppDelegate.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 12.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var menuObjects: NSArray?
        Bundle.main.loadNibNamed("MainMenu", owner: self, topLevelObjects: &menuObjects)
        let views = Array<Any>(menuObjects!).filter { $0 is NSMenu }
        NSApplication.shared.mainMenu = views.last as? NSMenu
        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.title = NSLocalizedString("general.title", comment: "")
        window.setFrameAutosaveName(NSLocalizedString("general.title", comment: ""))
        window.contentView = NSHostingView(rootView: SelectGroupView())
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func openSettings(_ sender: Any) {
        AlertService.getCurrentWindow().contentView = NSHostingView(
            rootView: SelectGroupView(currentView: SelectGroupView.VIEW_SETTINGS)
        )
    }
    
    @IBAction func openDocument(_ sender: Any) {
        do {
            let dialog = NSOpenPanel();
            dialog.title                   = NSLocalizedString("general.openJson", comment: "")
            dialog.showsResizeIndicator    = true
            dialog.canChooseDirectories    = false
            dialog.canCreateDirectories    = true
            dialog.allowsMultipleSelection = false
            dialog.allowedFileTypes        = ["json"];

            if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                let result = dialog.url // Pathname of the file
                if (result != nil) {
                    let jsonSettings = try String(contentsOf: result!, encoding: .utf8)
                    let settings = try SettingsService.shared.getFromJson(jsonString: jsonSettings)
                    try SettingsService.shared.persist(settings: settings)
                    openSettings(sender)
                }
            } else {
                // User clicked on "Cancel"
                return
            }
        } catch {
            AlertService.showErrorMessage(message: "\(error)")
        }
    }
    
    @IBAction func saveDocument(_ sender: Any) {
        do {
            let exportString: String = try SettingsService.shared.getAsJson(
                settings: SettingsService.shared.settings!
            )
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "Y-MM-dd-HH-mm-ss"
            
            let dialog = NSSavePanel();
            dialog.title                   = NSLocalizedString("general.exportJson", comment: "")
            dialog.nameFieldStringValue    = "export_ad-groups-for-mac_" + (dateFormatter.string(for: Date()) ?? "")
            dialog.showsResizeIndicator    = true
            dialog.canCreateDirectories    = true;
            dialog.allowedFileTypes        = ["json"];

            if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                let result = dialog.url // Pathname of the file
                if (result != nil) {
                    let path = result!.path
                    try exportString.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                }
            } else {
                // User clicked on "Cancel"
                return
            }
        } catch {
            AlertService.showErrorMessage(message: "\(error)")
        }
    }
    
    @IBAction func openHelp(_ sender: Any) {
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName(NSLocalizedString("general.helpTitle", comment: ""))
        window.contentView = NSHostingView(rootView: HelpView())
        window.makeKeyAndOrderFront(nil)
    }
}

struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        Text("App started")
    }
}
