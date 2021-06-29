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
        } else {
            self.settings!.loginPassword = loadPassword(settings: self.settings!) ?? ""
        }
    }
    
    public func persist(settings: Settings) throws {
        self.settings = settings
        addOrUpdatePassword(settings: settings)
        UserDefaults.standard.set(try self.getAsJson(settings: settings), forKey: self.storageKey)
    }
    
    public func getAsJson(settings: Settings) throws -> String {
        var settingsCopy = settings
        let password: String = settings.loginPassword
        settingsCopy.loginPassword = ""
        let jsonData = try JSONEncoder().encode(settingsCopy)
        settingsCopy.loginPassword = password
        return String(data: jsonData, encoding: .utf8)!
    }

    public func getFromJson(jsonString: String) throws -> Settings {
        let jsonData = jsonString.data(using: .utf8)
        return try JSONDecoder().decode(Settings.self, from: jsonData!)
    }

    private func addOrUpdatePassword(settings: Settings) {
        self.settings = settings
        let keychainItem = [
            kSecClass: kSecClassInternetPassword,
            kSecValueData: settings.loginPassword.data(using: .utf8)!,
            kSecAttrAccount: settings.loginName,
            kSecAttrServer: settings.ldapUrl,
            kSecAttrComment: "Created by 'AD Groups for Mac'"
        ] as CFDictionary
        let status = SecItemAdd(keychainItem, nil)

        if (status != 0) { // if password already exists, update it
            let query = [
                kSecClass: kSecClassInternetPassword,
                kSecAttrAccount: settings.loginName,
                kSecAttrServer: settings.ldapUrl,
                kSecAttrComment: "Created by 'AD Groups for Mac'"
            ] as CFDictionary

            let updateFields = [
                kSecValueData: settings.loginPassword.data(using: .utf8)!
            ] as CFDictionary
            SecItemUpdate(query, updateFields)
        }
    }

    private func loadPassword(settings: Settings) -> String? {
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: self.settings!.loginName,
            kSecAttrServer: self.settings!.ldapUrl,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if (status == 0) {
            let dic = result as! NSDictionary
            let passwordData = dic[kSecValueData] as! Data
            return String(data: passwordData, encoding: .utf8)!
        } else {
            return nil;
        }
    }
}
