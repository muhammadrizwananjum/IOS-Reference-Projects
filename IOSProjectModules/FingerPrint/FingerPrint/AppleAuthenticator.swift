//
//  AppleAuthenticator.swift
//  FingerPrint
//
//  Created by Rizwan on 01/05/2019.
//  Copyright © 2019 Anjum. All rights reserved.
//

import Foundation
import LocalAuthentication

public typealias AuthenticationCompletionBlock = () ->()
public typealias AuthenticationErrorBlock = (Int) -> ()

public class AppleAuthenticator : NSObject {
    
    fileprivate var context : LAContext
    
    // reason string presented to the user in auth dialog
    var reason : NSString
    
    // Allows fallback button title customization. If set to nil, "Enter Password" is used.
    var fallbackButtonTitle : NSString
    
    // If set to NO it will not customize the fallback title, shows default "Enter Password".  If set to YES, title is customizable.  Default value is NO.
    var useDefaultFallbackTitle : Bool
    
    // Disable "Enter Password" fallback button. Default value is NO.
    var hideFallbackButton : Bool
    
    // Default value is LAPolicyDeviceOwnerAuthenticationWithBiometrics.  This value will be useful if LocalAuthentication.framework introduces new auth policies in future version of iOS.
    var policy : LAPolicy
    
    
    public static var sharedInstance : AppleAuthenticator {
        struct Static {
            static let instance : AppleAuthenticator = AppleAuthenticator()
        }
        return Static.instance
    }
    
    override init(){
        self.context = LAContext()
        self.fallbackButtonTitle = "hello"
        self.useDefaultFallbackTitle = false
        self.hideFallbackButton = false
        if #available(iOS 9.0, *) {
            self.policy = .deviceOwnerAuthentication
        } else {
            self.policy = .deviceOwnerAuthenticationWithBiometrics
        }
        self.reason = "need this for auth purpose"
    }
    
    class func canAuthenticateWithError(error: NSErrorPointer) -> Bool{
        if (UserDefaults.standard.object(forKey: "touch_id_security") != nil){
            if UserDefaults.standard.bool(forKey: "touch_id_security") == false{
                return false
            }
        }
        else {
            return false
        }
        if ((NSClassFromString("LAContext")) != nil){
            if (AppleAuthenticator.sharedInstance.context .canEvaluatePolicy(AppleAuthenticator.sharedInstance.policy, error: nil)){
                return true
            }
            return false
        }
        return false
    }
    
    public func authenticateWithSuccess(_ success: @escaping AuthenticationCompletionBlock, failure: @escaping AuthenticationErrorBlock){
        self.context = LAContext()
        var authError : NSError?
        if (self.useDefaultFallbackTitle) {
            self.context.localizedFallbackTitle = self.fallbackButtonTitle as String;
        }else if (self.hideFallbackButton){
            self.context.localizedFallbackTitle = "";
        }
        if (self.context.canEvaluatePolicy(policy, error: &authError)) {
            self.context.evaluatePolicy(policy, localizedReason:
                reason as String, reply:{ authenticated, error in
                    if (authenticated) {
                        DispatchQueue.main.async(execute: {success()})
                    } else {
                        DispatchQueue.main.async(execute: {failure(error!._code)})
                    }
            })
        } else {
            failure(authError!.code)
        }
    }
}
