//
//  ViewController.swift
//  KeychainPasswordStorage
//
//  Created by Rizwan on 01/05/2019.
//  Copyright © 2019 Anjum. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    //MARK:- IBOutlet
    @IBOutlet weak var txtEmailField: UITextField!
    @IBOutlet weak var txtPasswordField: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    

    //MARK:- Variable
    var passwordItems = [KeychainPasswordItem]()
    
    
    //MARK:- override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadUserAauthentication ()
        
        if let passwordItem = self.passwordItems.first {
            
            self.txtEmailField.text = passwordItem.account
        }
    }
    
    //MARK:- Private Methods
    func loadUserAauthentication () {
        
        do {
            passwordItems = try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)
        }
        catch {
            fatalError("Error fetching password items - \(error)")
        }
    }
    
    func deleteUserAauthentication() {
        
        let passwordItem = self.passwordItems.first!
        do {
            try passwordItem.deleteItem()
        }
        catch {
            fatalError("Error deleting keychain item - \(error)")
        }
        
        // Delete the item from the `passwordItems` array.
        self.passwordItems.removeFirst()
    }
    
    func saveUserAauthentication() {
        // Check that text has been entered into both the account and password fields.
        guard let newAccountName = txtEmailField.text, let newPassword = txtPasswordField.text, !newAccountName.isEmpty && !newPassword.isEmpty else { return }
        
        // Check if we need to update an existing item or create a new one.
        do {
            if let originalAccountName = self.txtEmailField.text {
                // Create a keychain item with the original account name.
                var passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: originalAccountName, accessGroup: KeychainConfiguration.accessGroup)
                
                // Update the account name and password.
                try passwordItem.renameAccount(newAccountName)
                try passwordItem.savePassword(newPassword)
            }
            else {
                // This is a new account, create a new keychain item with the account name.
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: newAccountName, accessGroup: KeychainConfiguration.accessGroup)
                
                // Save the password for the new item.
                try passwordItem.savePassword(newPassword)
            }
        }
        catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:-  IBAction
    @IBAction func btnSignClicked(_ sender: UIButton) {
        
        self.saveUserAauthentication()
    }
}

