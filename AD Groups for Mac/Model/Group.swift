//
//  Group.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 13.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Foundation

struct Group {
    let dn: String
    let name: String
    var members: [String] = []
    let managedBy: String
    let info: String
    let description: String
}
