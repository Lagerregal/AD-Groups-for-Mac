//
//  UserStorage.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 13.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Foundation

class UserStorage {
    static let shared = UserStorage()

    private var objectCache: [String: User] = [:]

    private init() {
    }

    func getUser(dn: String) throws -> User? {
        if (objectCache[dn] == nil) {
            let rawUsers = try LdapConnection.shared.initConnection().findUsersByDn(dn: dn)
            for (userDn, rawUser) in rawUsers {
                objectCache[userDn] = self.getUserByRawData(dn: userDn, data: rawUser)
            }
        }
        return objectCache[dn];
    }
    
    func getUserByRawData(dn: String, data: [String:Any]) -> User {
        if (objectCache[dn] == nil) {
            var user = User(dn: dn)
            user.company = data["company"] as? String ?? ""
            user.department = data["department"] as? String ?? ""
            user.displayName = data["displayName"] as? String ?? ""
            user.location = data["l"] as? String ?? ""
            user.mail = data["mail"] as? String ?? ""
            user.mobile = data["mobile"] as? String ?? ""
            user.name = data["name"] as? String ?? ""
            objectCache[dn] = user
        }
        return objectCache[dn]!;
    }
}
