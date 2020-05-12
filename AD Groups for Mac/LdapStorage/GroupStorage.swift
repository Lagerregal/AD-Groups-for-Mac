//
//  GroupStorage.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 14.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Foundation

class GroupStorage {
    static let shared = GroupStorage()

    private var objectCache: [String: Group] = [:]

    private init() {
    }

    func getGroup(dn: String) throws -> Group? {
        if (objectCache[dn] == nil) {
            let rawGroups = try LdapConnection.shared.initConnection().findUsersByDn(dn: dn)
            for (groupDn, rawGroup) in rawGroups {
                objectCache[groupDn] = self.getGroupByRawData(dn: groupDn, data: rawGroup)
            }
        }
        return objectCache[dn];
    }
    
    func getGroupByRawData(dn: String, data: [String:Any]) -> Group {
        if (objectCache[dn] == nil) {
            let group: Group = Group(
                dn: dn,
                name: data["cn"] as? String ?? dn,
                managedBy: data["managedBy"] as? String ?? "",
                info: data["info"] as? String ?? "",
                description: data["description"] as? String ?? ""
            )
            objectCache[dn] = group
        }
        return objectCache[dn]!;
    }
    
    func getDummyPreviewGroup() -> Group {
        return Group(
            dn: "CN=Group_Name,OU=Test",
            name: "Group Name",
            managedBy: "",
            info: "",
            description: ""
        )
    }
}
