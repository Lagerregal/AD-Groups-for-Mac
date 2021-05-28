//
//  ContentView.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 12.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import SwiftUI

struct SelectGroupView: View {
    public static let VIEW_SETTINGS = 1
    
    @State private var groups: [Group] = []
    @State private var currentUser: User?
    @State public var currentView: Int? = 0

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    "Settings",
                    destination: SettingsView(),
                    tag: SelectGroupView.VIEW_SETTINGS,
                    selection: $currentView
                )
                Text("Welcome: " + (currentUser?.displayName ?? "not logged in"))
                Divider()
                List(groups, id: \.dn) { group in
                    NavigationLink(
                        group.name,
                        destination: GroupView(group: group)
                            .frame(maxWidth: .infinity, alignment: .top),
                        tag: group.name.hashValue,
                        selection: $currentView
                    )
                }
            }
                .frame(minWidth: 250, minHeight: 400)
            StartView()
                .padding(10)
                .frame(minWidth: 300, maxWidth: 300, minHeight: 500)
        }
        .onAppear(perform: {
            self.loadGroups()
        })
    }

    private func loadGroups() {
        do {
            print("loadGroups")
            let currentUserName = SettingsService.shared.settings!.ldapUser
            let rawUsers = try LdapConnection.shared.initConnection().findUsersByCn(name: currentUserName)
            if (rawUsers.count < 1) {
                throw ErrorMessage.runtimeError("No user found for: " + currentUserName)
            }
            let rawUser = rawUsers.first
            self.currentUser = UserStorage.shared.getUserByRawData(dn: rawUser!.key, data: rawUser!.value)

            let rawGroups = try LdapConnection.shared.findGroupsManagableByUser(userDn: self.currentUser!.dn)
            .sorted(by: { (el1, el2) -> Bool in
                el1.key.localizedCaseInsensitiveCompare(el2.key) == .orderedAscending
            })
            for(groupDn, groupData) in rawGroups {
                self.groups.append(GroupStorage.shared.getGroupByRawData(dn: groupDn, data: groupData))
            }
        } catch {
            if ((SettingsService.shared.settings?.ldapUrl.isEmpty) != nil) {
                print("No settings found")
            } else {
                print("connection error")
                AlertService.showErrorMessage(message: "\(error)")
            }
            currentView = SelectGroupView.VIEW_SETTINGS
        }
    }

    private func getFirstAttributeOfDn(fullDn: String, attribute: String) -> String? {
        let attributes = fullDn.split(separator: ",")
        var firstAttributeOfDn: String? = nil
        attributes.forEach { keyAndValue in
            let keyAndValueArr = keyAndValue.split(separator: "=")
            if (keyAndValueArr[0] == attribute) {
                firstAttributeOfDn = String(keyAndValueArr[1])
            }
        }
        return firstAttributeOfDn
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectGroupView()
    }
}
