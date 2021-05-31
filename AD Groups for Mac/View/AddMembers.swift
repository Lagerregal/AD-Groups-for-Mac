//
//  AddMember.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 13.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import SwiftUI

struct AddMembers: View {
    let group: Group
    @Binding var isPresented: Bool
    @State var groupView: GroupView?

    // inputs
    @State var userId: String = ""
    @State var searchQuery: String = ""

    // selection
    @State var foundUsers: [User] = []
    @State var selectedUserDn: String = ""

    // internal
    @State private var lastSearchHash: String = ""

    var body: some View {
        VStack {
            Text(LocalizedStringKey("view.addMembers.searchForUsers")).bold()
            HStack {
                TextField(LocalizedStringKey("view.addMembers.userId"), text: $userId, onCommit: searchUser)
                Text(LocalizedStringKey("view.addMembers.or"))
                TextField(LocalizedStringKey("view.addMembers.name"), text: $searchQuery, onCommit: searchUser)
            }
            Button(action: searchUser) {
                Text(LocalizedStringKey("view.addMembers.search"))
            }.focusable()
            Divider()
            Text(LocalizedStringKey("view.addMembers.pickUser")).bold()
            Picker(selection: self.$selectedUserDn, label: Text(LocalizedStringKey("view.addMembers.selectUser"))) {
                ForEach(self.foundUsers, id: \.dn) { user in
                    Text("\(user.displayName)(\(user.name))(\(user.company))").tag(user.dn)
                }
            }
            Divider()
            HStack {
                Button(action: {
                    do {
                        try LdapConnection.shared.initConnection().addMemberDnToGroup(
                            userDn: self.selectedUserDn,
                            groupDn: self.group.dn
                        )
                        self.isPresented.toggle()
                        self.groupView?.loadGroupMembers()
                    } catch {
                        AlertService.showErrorMessage(message: "\(error)")
                    }
                }) {
                    Text(LocalizedStringKey("view.addMembers.add"))
                }.focusable()
                Button(action: {
                    self.isPresented.toggle()
                }) {
                    Text(LocalizedStringKey("view.addMembers.cancel"))
                }.focusable()
            }
        }
        .frame(width: 600, height: 400)
        .padding(20)
    }
    
    func searchUser() -> Void {
        do {
            let newSearchHash = self.searchQuery + "_" + self.userId
            if (newSearchHash != self.lastSearchHash) {
                self.lastSearchHash = newSearchHash
                self.foundUsers = []
                var foundUsersRaw: [String:[String:Any]] = [:]

                if (!searchQuery.isEmpty) {
                    foundUsersRaw = try LdapConnection.shared.initConnection().findUsersByFullText(query: searchQuery)
                } else if(!userId.isEmpty) {
                    foundUsersRaw = try LdapConnection.shared.initConnection().findUsersByCn(name: userId)
                }
                
                if (foundUsersRaw.count > 0) {
                    var i = 0;
                    for(userDn, rawUser) in foundUsersRaw {
                        self.foundUsers.append(UserStorage.shared.getUserByRawData(dn: userDn, data: rawUser))
                        if (i == 0) {
                            self.selectedUserDn = userDn
                        }
                        i += 1
                    }
                }
            }
        } catch {
            AlertService.showErrorMessage(message: "\(error)")
        }
    }
}

struct AddMember_Previews: PreviewProvider {
    static var previews: some View {
        AddMembers(group: Group(dn: "", name: "", managedBy: "", info: "", description: ""), isPresented: .constant(true))
    }
}
