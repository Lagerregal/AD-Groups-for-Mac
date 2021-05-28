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
        return "Name: \(name)\n" +
            "Display Name: \(displayName)\n" +
            "Company: \(company)\n" +
            "Email: \(mail)\n" +
            "Mobile: \(mobile)\n" +
            "Location: \(location)\n" +
            "Department: \(department)\n" +
            "DN: \(dn)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dn)
    }
}
