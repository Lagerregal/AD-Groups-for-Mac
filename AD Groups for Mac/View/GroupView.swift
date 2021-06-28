//
//  GroupView.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 13.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    @State var group: Group
    @State var showAddMembersModal = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey("view.group.group")).bold() + Text(group.name)
            Divider()
            Text(LocalizedStringKey("view.group.dn")).bold() + Text(group.dn)
            Divider()
            Text(LocalizedStringKey("view.group.managedBy")).bold() + Text(group.managedBy)
            Divider()
            Text(LocalizedStringKey("view.group.description")).bold() + Text(group.description)
            Divider()
            HStack {
                Text(LocalizedStringKey("view.group.members")).bold()
                Button(action: {
                    self.showAddMembersModal.toggle()
                }) {
                    Label(LocalizedStringKey("view.group.addMember"), systemImage: "plus")
                }.sheet(isPresented: $showAddMembersModal) {
                    AddMembers(group: self.group, isPresented: self.$showAddMembersModal, groupView: self)
                }
            }
            List(group.members, id: \.self) { member in
                SimpleUserView(user: User(dn: member), group: self.group, groupView: self)
            }
        }
        .frame(minWidth: 500, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .onAppear(perform: {
            self.loadGroupMembers()
        })
    }
    
    func loadGroupMembers() {
        do {
            print("loadGroupMembers " + self.group.dn)
            self.group.members = try LdapConnection.shared.initConnection().findGroupMembersDn(groupDn: self.group.dn)
        } catch {
            print("connection error")
            AlertService.showErrorMessage(message: "\(error)")
            AlertService.getCurrentWindow().contentView = NSHostingView(rootView: SettingsView())
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView(group: GroupStorage.shared.getDummyPreviewGroup())
    }
}
