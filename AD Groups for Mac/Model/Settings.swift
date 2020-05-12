//
//  Settings.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 14.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Foundation

struct Settings: Codable {
    var ldapUrl: String = ""
    var ldapBasePath: String = ""
    var ldapUser: String = ""
    var loginName: String = ""
    var loginPassword: String = ""
}
