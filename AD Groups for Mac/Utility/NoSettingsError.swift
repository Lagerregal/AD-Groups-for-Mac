//
//  NoSettingsError.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 29.06.21.
//  Copyright © 2021 different.technology. All rights reserved.
//

import Foundation

enum NoSettingsError: Error {
    case noLdapUrl
    case noLdapUser
    case noLoginName
    case noLoginPassword
}
