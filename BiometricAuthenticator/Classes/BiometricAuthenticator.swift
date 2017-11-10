//
//  BiometricAuthenticator.swift
//  BiometricAuthenticator
//
//  Created by Christopher Corea on 11/7/17.
//

import Foundation
import LocalAuthentication

/**
 The BiometricAuthenticator relies on the Local Authentication module's provided
 error codes. The relevant error codes are below with a bit about what they cover.
 
 ```appCancel``` - The application cancelled the biometric prompt
 
 ```authenticationFailed``` - The provided fingerprint or face was not recognized by iOS

 ```biometryLockout``` - Authentication could not continue because the user has been locked
                    out of biometric authentication, due to failing authentication too many times.
 
 ```biometryNotAvailable``` - Authentication could not start because the device does not support
                        biometric authentication.

 ```biometryNotEnrolled``` - Authentication could not start because the user has not enrolled in
                        biometric authentication.
 
 ```passcodeNotSet``` - Authentication could not start because the passcode is not set on the device.
 
 ```systemCancel``` - Authentication was canceled by the system (can be caused by another application
                taking foreground while the authentication dialog was up)
 
 ```userCancel``` - User cancelled by clicking the cancel option in the authentication dialog.
 
 ```userFallback``` - Authentication was canceled because the user tapped the fallback button in the
                authentication dialog, but no fallback is available for the authentication policy.

 */
public typealias BAFailureBlock = ((_ error: LAError?) -> Void)?
public typealias BASuccessBlock = (() -> Void)?

public class BiometricAuthenticator {
    
    public init() {}
    
    /// Checks if the current device model can support Touch ID.
    ///
    /// - Returns: True if the device is known to support Touch ID.
    public func isTouchIdSupportedOnDevice() -> Bool {
        return UIDevice.current.supportsTouchId()
    }
    
    /// CHecks if the device can support Touch ID and whether or not Touch ID is enabled.
    ///
    /// - Returns: True if the device can support Touch ID and the feature is enabled.
    public func isTouchIdEnabledOnDevice() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && isTouchIdSupportedOnDevice()
    }
    
    /// Checks if the current device model can support Face ID.
    ///
    /// - Returns: True if the device is known to support Face ID.
    public func isFaceIdSupportedOnDevice() -> Bool {
        return UIDevice.current.supportsFaceId()
    }
    
    /// CHecks if the device can support Face ID and whether or not Face ID is enabled.
    ///
    /// - Returns: True if the device can support Face ID and the feature is enabled.
    public func isFaceIdEnabledOnDevice() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && isFaceIdSupportedOnDevice()
    }
    
    /// Use this function to authenticate a user if biometric authentication is enabled on the user's phone.
    ///
    /// - Parameters:
    ///   - localizedReason: The string displayed to the user explaining why the application is requesting authentication.
    ///   - successBlock: A function or block of code executed if authentication succeeds.
    ///   - failureBlock: A function or block of code executed if authentication fails. The function takes a single LAError as
    ///                   a parameter. Use the error code provided in the LAError object to handle the authentication failure
    ///                   appropriately.
    public func authenticateWithBiometrics(localizedReason: String?, successBlock: BASuccessBlock, failureBlock: BAFailureBlock) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason ?? "Use Biometrics!") { (success, error) in
            if success {
                successBlock?()
            } else {
                guard let error = error as? LAError else {
                    failureBlock?(nil)
                    return
                }
                failureBlock?(error)
            }
        }
    }
    
    /// Use this function to authenticate a user if biometric authentication isn't enabled on the user's phone.
    ///
    /// - Note:
    ///     If the provided functions for determining whether or not biometric capabilities are available on the device
    ///     return true, ```authenticateWithBiometrics``` should be called instead.
    ///
    /// - Parameters:
    ///   - localizedReason: The string displayed to the user explaining why the application is requesting authentication.
    ///   - successBlock: A function or block of code executed if authentication succeeds.
    ///   - failureBlock: A function or block of code executed if authentication fails. The function takes a single LAError as
    ///                   a parameter. Use the error code provided in the LAError object to handle the authentication failure
    ///                   appropriately.
    public func authenticateWithPasscode(localizedReason: String?, successBlock: BASuccessBlock, failureBlock: BAFailureBlock) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason ?? "Default Text") { (success, error) in
            if success {
                successBlock?()
            } else {
                guard let error = error as? LAError else {
                    failureBlock?(nil)
                    return
                }
                failureBlock?(error)
            }
        }
    }
    
}
