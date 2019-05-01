//
//  ViewController.swift
//  FingerPrint
//
//  Created by Rizwan on 01/05/2019.
//  Copyright © 2019 Anjum. All rights reserved.
//

import UIKit
import LocalAuthentication


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func authenticate(_ sender: Any) {
        
        AppleAuthenticator.sharedInstance.authenticateWithSuccess({ [unowned self] () in
            self.presentAlertControllerWithMessage("Successfully Authenticated!")
        }) { (errorCode) in
            var authErrorString : NSString
            switch (errorCode) {
            case LAError.systemCancel.rawValue:
                authErrorString = "System canceled auth request due to app coming to foreground or background.";
                break;
            case LAError.authenticationFailed.rawValue:
                authErrorString = "User failed after a few attempts.";
                break;
            case LAError.userCancel.rawValue:
                authErrorString = "User cancelled.";
                break;
                
            case LAError.userFallback.rawValue:
                authErrorString = "Fallback auth method should be implemented here.";
                break;
            case LAError.biometryNotEnrolled.rawValue:
                authErrorString = "No Touch ID fingers enrolled.";
                break;
            case LAError.biometryNotAvailable.rawValue:
                authErrorString = "Touch ID not available on your device.";
                break;
            case LAError.passcodeNotSet.rawValue:
                authErrorString = "Need a passcode set to use Touch ID.";
                break;
            default:
                authErrorString = "Check your Touch ID Settings.";
                break;
            }
            self.presentAlertControllerWithMessage(authErrorString)
        }
    }
    
    func presentAlertControllerWithMessage(_ message : NSString) {
        let alertController = UIAlertController(title:"Touch ID", message:message as String, preferredStyle:.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- KeyChain
    fileprivate func saveAccountDetailsToKeychain(account: String, password: String) {
        guard account.isEmpty, password.isEmpty else { return }
        UserDefaults.standard.set(account, forKey: "lastAccessedUserName")
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            try passwordItem.savePassword(password)
        } catch {
            print("Error saving password")
        }
    }
    
    fileprivate func loadPasswordFromKeychainAndAuthenticateUser(_ account: String) {
        guard !account.isEmpty else { return }
        let passwordItem = KeychainPasswordItem(service:   KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            let storedPassword = try passwordItem.readPassword()
            authenticateUser(storedPassword)
        } catch KeychainPasswordItem.KeychainError.noPassword {
            print("No saved password")
        } catch {
            print("Unhandled error")
        }
    }
    view raw
}

