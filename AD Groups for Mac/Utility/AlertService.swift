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
        let message = getCleanErrorMessage(message: message)
        print("Error " + message)
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
    
    static private func getCleanErrorMessage(message: String) -> String {
        var newMessage: String = message
        if ((message.hasPrefix("message(\"") || message.hasPrefix("runtimeError(\"")) && message.hasSuffix("\")")) {
            if (message.hasPrefix("message(\"")) {
                newMessage.removeFirst(9)
            }else if (message.hasPrefix("runtimeError(\"")) {
                newMessage.removeFirst(14)
            }
            newMessage.removeLast(2)
            newMessage = newMessage.replacingOccurrences(of: "\\'", with: "'")
        }
        return newMessage
    }
}
