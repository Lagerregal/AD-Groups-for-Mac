//
//  SimpleUserView.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 13.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import SwiftUI

struct SimpleUserView: View {
    @State var user: User
    @State var group: Group
    @State var groupView: GroupView?
    @State private var showPopover: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(user.displayName.isEmpty ? user.dn : user.displayName).frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    self.showPopover.toggle()
                }) {
                    Text("i")
                }
                Button(action: {
                    do {
                        try LdapConnection.shared.removeMemberDnFromGroup(userDn: self.user.dn, groupDn: self.group.dn)
                        self.groupView?.loadGroupMembers()
                    } catch {
                        AlertService.showErrorMessage(message: "\(error)")
                    }
                }) {
                    Text("x")
                }
            }
            Divider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear(perform: {
            self.loadUserInfo()
        })
        .popover(
            isPresented: self.$showPopover
        ) { Text(self.user.dumpInfo()).padding(10) }
    }
    
    private func loadUserInfo() {
        do {
            user = try UserStorage.shared.getUser(dn: user.dn) ?? user
        } catch {
            AlertService.showErrorMessage(message: "\(error)")
        }
    }
}

struct SimpleUserView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleUserView(
            user: User(dn: "test"),
            group: GroupStorage.shared.getDummyPreviewGroup(),
            groupView: nil
        )
    }
}
