//
//  LdapConnection.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 12.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Foundation
import PerfectLDAP

/// C library of OpenLDAP
import OpenLDAP
///// C library of SASL
//import SASL

class LdapConnection {
    static let shared = LdapConnection()

    let fetchUserAttributes: [String] = ["name", "displayName", "company", "mail", "mobile", "l", "department"]

    private var connection: LDAP?
    private var isInitialized: Bool = false
    private var settings: Settings = SettingsService.shared.settings!
    
    private init() {
    }
    
    func initConnection(force: Bool = false) throws -> LdapConnection {
        if (!isInitialized || force) {
            self.settings = SettingsService.shared.settings!
            let credentials = LDAP.Login(
                binddn: self.settings.loginName,
                password: self.settings.loginPassword
            )
            connection = try LDAP(
                url: self.settings.ldapUrl,
                loginData: credentials
            )
            connection?.timeout = 10
            connection?.limitation = 1000
            isInitialized = true
        }
        return self
    }

    func findUsersByCn(name: String) throws -> [String:[String:Any]] {
        return try connection!.search(
            base: self.settings.ldapBasePath,
            filter: "(&(cn=" + name + ")(objectClass=user))",
            scope: .SUBTREE,
            attributes: fetchUserAttributes
        )
    }

    func findUsersByDn(dn: String) throws -> [String:[String:Any]] {
        return try connection!.search(
            base: dn,
            filter: "(objectClass=user)",
            scope: .BASE,
            attributes: fetchUserAttributes
        )
    }

    func findUsersByFullText(query: String) throws -> [String:[String:Any]] {
        return try connection!.search(
            base: self.settings.ldapBasePath,
            filter: "(&" +
                "(objectClass=user)" +
                "(|" +
                    "(mail=*" + query + "*)" +
                    "(displayName=*" + query + "*)" +
                ")" +
            ")",
            scope: .SUBTREE,
            attributes: fetchUserAttributes
        )
    }

    func findManagableGroupsWithUserAsMember(userDn: String) throws -> [String:[String:Any]] {
        return try connection!.search(base: self.settings.ldapBasePath, filter: "(&" +
            "(member=" + userDn + ")" +
            "(managedBy=*)" +
            "(objectClass=group)" +
            ")", scope: .SUBTREE, attributes: ["cn", "description", "info", "managedBy"])
    }
    
    func findGroupsManagableByUser(userDn: String) throws -> [String:[String:Any]] {
        let groups = try findManagableGroupsWithUserAsMember(userDn: userDn)
        var managableGroups: [String:[String:Any]] = [:]
        for(groupDn, group) in groups {
            let managedBy = group["managedBy"] as? String ?? ""
            if (!managedBy.isEmpty) {
                if (groups[managedBy] != nil || managedBy == userDn) {
                    managableGroups[groupDn] = group
                }
            }
        }
        return managableGroups
    }
    
    func findGroupMembersDn(groupDn: String) throws -> [String] {
        let groups: [String:[String:Any]] = try connection!.search(base: groupDn, filter: "(objectClass=group)", scope: .BASE, attributes: ["member"]) as [String:[String:Any]]
        var members: [String] = []
        if (groups.count > 0) {
            if let firstGroup = groups.first {
                let member = firstGroup.value["member"]
                if (member is String) {
                    members.append(member as! String)
                } else {
                    members = member as! [String]
                }
            }
        }
        return members
    }
    
    func addMemberDnToGroup(userDn: String, groupDn: String) throws {
        try connection!.modify(
            distinguishedName: groupDn,
            attributes: ["member": [userDn]],
            method: (LDAP_MOD_ADD | LDAP_MOD_BVALUES)
        )
    }
    
    func removeMemberDnFromGroup(userDn: String, groupDn: String) throws {
        try connection!.modify(
            distinguishedName: groupDn,
            attributes: ["member": [userDn]],
            method: (LDAP_MOD_DELETE | LDAP_MOD_BVALUES)
        )
    }

}
