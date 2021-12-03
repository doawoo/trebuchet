//
//  ViewController.swift
//  trebuchet
//
//  Created by Digit on 12/1/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the current streamable credentials from the keychain
        let currentUsername = getStreamableUsername()
        let currentPassword = getStreamablePassword()
        
        if currentUsername != "" {
            self.usernameField.stringValue = getStreamableUsername()
        }
        
        if currentPassword != "" {
            self.passwordField.stringValue = getStreamablePassword()
        }
    }

    override var representedObject: Any? {
        didSet {}
    }
    
    @IBAction func saveAndClose(_ sender: AnyObject?) {
        if self.usernameField.stringValue == getStreamableUsername() && self.passwordField.stringValue == getStreamablePassword() {
            exit(0)
        }

        clearStremableCreds()
        createNewStreamableCredentials(username: self.usernameField.stringValue, password: self.passwordField.stringValue)
        exit(0)
    }
}

