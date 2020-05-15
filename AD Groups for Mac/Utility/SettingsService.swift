//
//  SettingsService.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 14.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import Foundation

class SettingsService {
   
    static let shared = SettingsService()
    
    public var settings: Settings? = nil
    
    private let storageKey: String = "DT/Settings"

    private init() {
        do {
            let settingsAsJson: String? = UserDefaults.standard.string(forKey: self.storageKey)
            if (settingsAsJson != nil && settingsAsJson != "") {
                self.settings = try self.getFromJson(jsonString: settingsAsJson!)
            }
        } catch { }

        if (self.settings == nil) {
            self.settings = Settings()
        }
    }
    
    public func persist(settings: Settings) throws {
        self.settings = settings
        UserDefaults.standard.set(try self.getAsJson(settings: settings), forKey: self.storageKey)
    }
    
    public func getAsJson(settings: Settings, removePassword: Bool = false) throws -> String {
        var settingsCopy = settings
        var password: String = ""
        if (removePassword) {
            password = settings.loginPassword
            settingsCopy.loginPassword = ""
        }
        let jsonData = try JSONEncoder().encode(settingsCopy)
        if (removePassword) {
            settingsCopy.loginPassword = password
        }
        return String(data: jsonData, encoding: .utf8)!
    }

    public func getFromJson(jsonString: String) throws -> Settings {
        let jsonData = jsonString.data(using: .utf8)
        return try JSONDecoder().decode(Settings.self, from: jsonData!)
    }
}
