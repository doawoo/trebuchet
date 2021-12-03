//
//  Keychain.swift
//  BarkBark
//
//  Created by Digit on 11/27/21.
//

import Foundation

let kSecAttrAccountKey_username = "surf.puppy.streamable_username"
let kSecAttrAccountKey_password = "surf.puppy.streamable_password"

func clearStremableCreds() {
    let queryUsername = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: kSecAttrAccountKey_username,
    ] as CFDictionary
    
    let queryPassword = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: kSecAttrAccountKey_password,
    ] as CFDictionary
    
    _ = SecItemDelete(queryUsername)
    _ = SecItemDelete(queryPassword)
}

func createNewStreamableCredentials(username: String, password: String) {
    // Clean any existing ones
    clearStremableCreds()
    
    let queryPassword = [
        kSecClass       : kSecClassGenericPassword,
        kSecAttrAccount : kSecAttrAccountKey_password,
        kSecValueData   : password
    ] as CFDictionary
    
    let queryUsername = [
        kSecClass       : kSecClassGenericPassword,
        kSecAttrAccount : kSecAttrAccountKey_username,
        kSecValueData   : username
    ] as CFDictionary
    
    let statusUsername = SecItemAdd(queryUsername, nil)
    let statusPassword = SecItemAdd(queryPassword, nil)
    
    if statusUsername != errSecSuccess || statusPassword != errSecSuccess {
        NSLog("Failed to update Streamable credentials!")
        NSLog(statusUsername.description)
        NSLog(statusPassword.description)
    }
}

func getStreamableUsername() -> String {
    let query = [
        kSecClass       : kSecClassGenericPassword,
        kSecAttrAccount : kSecAttrAccountKey_username,
        kSecReturnData  : kCFBooleanTrue as Any,
        kSecMatchLimit  : kSecMatchLimitOne
    ] as CFDictionary
    
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query, &dataTypeRef)
    
    if status == noErr && dataTypeRef != nil {
        let str = String(decoding: dataTypeRef as! Data, as: UTF8.self)
        return str
    }
    
    return ""
}

func getStreamablePassword() -> String {
    let query = [
        kSecClass       : kSecClassGenericPassword,
        kSecAttrAccount : kSecAttrAccountKey_password,
        kSecReturnData  : kCFBooleanTrue as Any,
        kSecMatchLimit  : kSecMatchLimitOne
    ] as CFDictionary
    
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query, &dataTypeRef)
    
    if status == noErr && dataTypeRef != nil {
        let str = String(decoding: dataTypeRef as! Data, as: UTF8.self)
        return str
    }
    
    return ""
}
