//
//  User.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 13.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Foundation

struct User: Hashable {
    let dn: String
    var name: String = ""
    var displayName: String = ""
    var company: String = ""
    var mail: String = ""
    var mobile: String = ""
    var location: String = ""
    var department: String = ""
    
    func dumpInfo() -> String {
        return "name: \(name)\n" +
            "displayName: \(displayName)\n" +
            "company: \(company)\n" +
            "mail: \(mail)\n" +
            "mobile: \(mobile)\n" +
            "location: \(location)\n" +
            "department: \(department)\n" +
            "dn: \(dn)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dn)
    }
}
