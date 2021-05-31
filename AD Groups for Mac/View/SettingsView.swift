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
            Text(
                LocalizedStringKey("view.settings.settings")
            ).font(.largeTitle).padding(.bottom, 20)
            Section(header: Text(LocalizedStringKey("view.settings.ldapSettings"))) {
                TextField(
                    LocalizedStringKey("view.settings.ldapUrl"),
                    text: self.$settings.ldapUrl
                )
                TextField(
                    LocalizedStringKey("view.settings.ldapBase"),
                    text: self.$settings.ldapBasePath
                )
                TextField(
                    LocalizedStringKey("view.settings.ldapUser"),
                    text: self.$settings.ldapUser
                )
            }
            Spacer().frame(height: 30)
            Section(header: Text(LocalizedStringKey("view.settings.credentials"))) {
                TextField(
                    LocalizedStringKey("view.settings.loginName"),
                    text: self.$settings.loginName
                )
                SecureField(
                    LocalizedStringKey("view.settings.loginPassword"),
                    text: self.$settings.loginPassword,
                    onCommit: {
                        saveSettings()
                    }
                )
            }
            Button(action: saveSettings) {
                Text(LocalizedStringKey("view.settings.save"))
            }.padding([.top, .bottom], 15)
            Divider()
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    let delegate = (NSApplication.shared.delegate) as! AppDelegate
                    delegate.openDocument(self)
                }) {
                    Text(LocalizedStringKey("view.settings.importSettings"))
                }
                Button(action: {
                    let delegate = (NSApplication.shared.delegate) as! AppDelegate
                    delegate.saveDocument(self)
                }) {
                    Text(LocalizedStringKey("view.settings.exportSettings"))
                }
            }
        }.frame(height: 600).padding(10)
    }
    
    private func saveSettings() -> Void {
        if (self.settings.loginPassword.isEmpty) {
            AlertService.showErrorMessage(message: NSLocalizedString(
                "view.settings.pleaseEnterYourPassword",
                comment: ""
            ))
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
            AlertService.showErrorMessage(message: NSLocalizedString(
                "view.settings.ldapPrefixMessage",
                comment: ""
            ))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
