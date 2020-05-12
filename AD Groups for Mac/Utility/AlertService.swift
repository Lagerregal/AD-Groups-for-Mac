//
//  AlertService.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 12.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import SwiftUI

class AlertService {
   
    static func showErrorMessage(message: String) -> Void {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        let window = getCurrentWindow()
        alert.beginSheetModal(for: window){ (response) in
            return
        }
        return
    }
    
    static func getCurrentWindow() -> NSWindow {
        return NSApplication.shared.windows.first!
    }
}
