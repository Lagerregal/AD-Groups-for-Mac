//
//  SettingsView.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 12.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var settings: Settings = SettingsService.shared.settings!
    
    var body: some View {
        Form {
            Text("Settings").font(.largeTitle).padding(.bottom, 20)
            Section(header: Text("LDAP Settings")) {
                TextField("LDAP URL", text: self.$settings.ldapUrl)
                TextField("LDAP Base", text: self.$settings.ldapBasePath)
                TextField("LDAP User", text: self.$settings.ldapUser)
            }
            Spacer().frame(height: 30)
            Section(header: Text("Credentials")) {
                TextField("Login Name", text: self.$settings.loginName)
                SecureField("Login Password", text: self.$settings.loginPassword, onCommit: {
                    saveSettings()
                })
            }
            Button(action: saveSettings) {
                Text("Save")
            }.padding([.top, .bottom], 15)
            Divider()
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    let delegate = (NSApplication.shared.delegate) as! AppDelegate
                    delegate.openDocument(self)
                }) {
                    Text(LocalizedStringKey("Import settings"))
                }
                Button(action: {
                    let delegate = (NSApplication.shared.delegate) as! AppDelegate
                    delegate.saveDocument(self)
                }) {
                    Text("Export Settings")
                }
            }
        }.frame(height: 600).padding(10)
    }
    
    private func saveSettings() -> Void {
        if (self.settings.loginPassword.isEmpty) {
            AlertService.showErrorMessage(message: "Please enter your password")
            return
        }
        if (self.settings.ldapUrl.hasPrefix("ldaps://") || self.settings.ldapUrl.hasPrefix("ldap://")) {
            do {
                // persist new settings
                try SettingsService.shared.persist(settings: self.settings)
                // try to connect
                try LdapConnection.shared.initConnection(force: true)
                // redirect to main page
                AlertService.getCurrentWindow().contentView = NSHostingView(rootView: SelectGroupView())
            } catch {
                print("connection error")
                AlertService.showErrorMessage(message: "\(error)")
            }
        } else {
            AlertService.showErrorMessage(message: "LDAP URL has to start with ldaps:// or ldap://")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
