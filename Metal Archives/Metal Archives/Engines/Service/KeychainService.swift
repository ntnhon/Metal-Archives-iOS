//
//  KeychainService.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import KeychainAccess

final class KeychainService {
    private static let keychain = Keychain(service: "info.nguyenthanhnhon.Metal-Archives")
    private static let usernameKey = "username"
    private static let passwordKey = "password"
    
    static func isHavingUserCredential() -> Bool {
        return keychain[usernameKey] != nil && keychain[passwordKey] != nil
    }
    
    static func getUsername() -> String {
        return keychain[usernameKey] ?? ""
    }
    
    static func getPassword() -> String {
        return keychain[passwordKey] ?? ""
    }
    
    static func save(username: String, password: String) {
        keychain[usernameKey] = username
        keychain[passwordKey] = password
    }
    
    static func removeUserCredential() {
        keychain[usernameKey] = nil
        keychain[passwordKey] = nil
    }
}
