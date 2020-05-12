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
            Text("1. Search for users").bold()
            HStack {
                TextField("User ID", text: $userId, onCommit: searchUser)
                Text("or")
                TextField("Name", text: $searchQuery, onCommit: searchUser)
            }
            Button(action: searchUser) {
                Text("Search")
            }.focusable()
            Divider()
            Text("2. Pick user").bold()
            Picker(selection: self.$selectedUserDn, label: Text("Select user: ")) {
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
                    Text("Add")
                }.focusable()
                Button(action: {
                    self.isPresented.toggle()
                }) {
                    Text("Cancel")
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
