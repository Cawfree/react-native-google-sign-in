//
//  RNGoogleSignIn.swift
//
//  Created by Joon Ho Cho on 1/16/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation

@objc(RNGoogleSignIn)
class RNGoogleSignIn: NSObject, GIDSignInUIDelegate, GIDSignInDelegate {
  
  static func userToJSON(_ user: GIDGoogleUser?) -> [String: Any]? {
    if let user = user {
      var body: [String: Any] = [:]
      
      if let userID = user.userID {
        body["userID"] = userID
      }
      
      if let profile = user.profile {
        if let email = profile.email {
          body["email"] = email
        }
        if let name = profile.name {
          body["name"] = name
        }
        if let givenName = profile.givenName {
          body["givenName"] = givenName
        }
        if let familyName = profile.familyName {
          body["familyName"] = familyName
        }
        if profile.hasImage {
          if let url = profile.imageURL(withDimension: 320)?.absoluteString {
            body["imageURL320"] = url
          }
          if let url = profile.imageURL(withDimension: 640)?.absoluteString {
            body["imageURL640"] = url
          }
          if let url = profile.imageURL(withDimension: 1280)?.absoluteString {
            body["imageURL1280"] = url
          }
        }
      }
      
      if let authentication = user.authentication {
        if let clientID = authentication.clientID {
          body["clientID"] = clientID
        }
        if let accessToken = authentication.accessToken {
          body["accessToken"] = accessToken
        }
        if let accessTokenExpirationDate = authentication.accessTokenExpirationDate {
          body["accessTokenExpirationDate"] = accessTokenExpirationDate.timeIntervalSince1970
        }
        if let refreshToken = authentication.refreshToken {
          body["refreshToken"] = refreshToken
        }
        if let idToken = authentication.idToken {
          body["idToken"] = idToken
        }
        if let idTokenExpirationDate = authentication.idTokenExpirationDate {
          body["idTokenExpirationDate"] = idTokenExpirationDate.timeIntervalSince1970
        }
      }
      
      if let accessibleScopes = user.accessibleScopes {
        body["accessibleScopes"] = accessibleScopes
      }
      
      if let grantedScopes = user.grantedScopes {
        body["grantedScopes"] = grantedScopes
      }
      
      if let hostedDomain = user.hostedDomain {
        body["hostedDomain"] = hostedDomain
      }
      
      if let serverAuthCode = user.serverAuthCode {
        body["serverAuthCode"] = serverAuthCode
      }
      
      return body
    } else {
      return nil
    }
  }

  static let sharedInstance = RNGoogleSignIn()
  
  // TODO: How to make thread safe?
  static var emitters = [RNGoogleSignInEvents]()

  //weak var events: RNGoogleSignInEvents?

  override init() {
    super.init()
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().delegate   = self
  }

  //  @objc func addEvent(_ name: String, location: String, date: NSNumber, callback: @escaping (Array<String>) -> ()) -> Void {
  //    NSLog("%@ %@ %@", name, location, date)
  //    self.callback = callback
  //  }

  @objc func configureGIDSignIn() {
    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
      if let plistDict = NSDictionary(contentsOfFile: filePath) {
        if let clientID = plistDict["CLIENT_ID"] as? String {
          GIDSignIn.sharedInstance().clientID = clientID
        } else {
          print("RNGoogleSignIn Error: CLIENT_ID is invalid in GoogleService-Info.plist")
        }
      } else {
        print("RNGoogleSignIn Error: GoogleService-Info.plist is malformed")
      }
    } else {
      print("RNGoogleSignIn Error: GoogleService-Info.plist not found")
    }
  }

  @objc func configure(_ config: [String: Any]) {
    if let instance = GIDSignIn.sharedInstance() {
      if let clientID = config["clientID"] as? String {
        instance.clientID = clientID
      }
      if let scopes = config["scopes"] as? [String] {
        instance.scopes = scopes
      }
      if let shouldFetchBasicProfile = config["shouldFetchBasicProfile"] as? Bool {
        instance.shouldFetchBasicProfile = shouldFetchBasicProfile
      }
      if let language = config["language"] as? String {
        instance.language = language
      }
      if let loginHint = config["loginHint"] as? String {
        instance.loginHint = loginHint
      }
      if let serverClientID = config["serverClientID"] as? String {
        instance.serverClientID = serverClientID
      }
      if let openIDRealm = config["openIDRealm"] as? String {
        instance.openIDRealm = openIDRealm
      }
      if let hostedDomain = config["hostedDomain"] as? String {
        instance.hostedDomain = hostedDomain
      }
    }
  }
  
  @objc func signIn() {
    DispatchQueue.main.async {
      GIDSignIn.sharedInstance().signIn()
    }
  }

  @objc func signOut(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    GIDSignIn.sharedInstance().signOut()
    if GIDSignIn.sharedInstance().currentUser == nil {
      resolve(nil)
    } else {
      reject("SignOutFailed", "Failed to sign out", nil)
    }
  }

  @objc func signInSilently() {
    DispatchQueue.main.async {
      GIDSignIn.sharedInstance().signInSilently()
    }
  }
  
  @objc func disconnect() {
    DispatchQueue.main.async {
      GIDSignIn.sharedInstance().disconnect()
    }
  }
  
  @objc func currentUser(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    resolve(RNGoogleSignIn.userToJSON(GIDSignIn.sharedInstance().currentUser))
  }
  
  @objc func hasAuthInKeychain(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    resolve(GIDSignIn.sharedInstance().hasAuthInKeychain())
  }
  
  @objc func constantsToExport() -> [String: Any] {
    return [
      "dark": "dark",
      "light": "light",
      "iconOnly": "iconOnly",
      "standard": "standard",
      "wide": "wide",
      "ErrorCode": [
        "unknown": GIDSignInErrorCode.unknown.rawValue,
        "keychain": GIDSignInErrorCode.keychain.rawValue,
        "noSignInHandlersInstalled": GIDSignInErrorCode.noSignInHandlersInstalled.rawValue,
        "hasNoAuthInKeychain": GIDSignInErrorCode.hasNoAuthInKeychain.rawValue,
        "canceled": GIDSignInErrorCode.canceled.rawValue,
      ],
    ]
  }
  
  
  // START: GIDSignInUIDelegate
  
  func sign(inWillDispatch signIn: GIDSignIn!, error: Error?) {
    // TODO: Refactor?
    self.dispatch(error: error)
  }
	
  func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
    viewController.dismiss(animated: true, completion: nil)
  }
  
  func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
    let _ = present(viewController: viewController)
  }

  func getTopViewController(window: UIWindow?) -> UIViewController? {
    if let window = window {
      var top = window.rootViewController
      while true {
        if let presented = top?.presentedViewController {
          top = presented
        } else if let nav = top as? UINavigationController {
          top = nav.visibleViewController
        } else if let tab = top as? UITabBarController {
          top = tab.selectedViewController
        } else {
          break
        }
      }
      return top
    }
    return nil
  }

  func present(viewController: UIViewController) -> Bool {
    if let topVc = getTopViewController(window: UIApplication.shared.keyWindow) {
      topVc.present(viewController, animated: true, completion: nil)
      return true
    }
    return false
  }

  // END: GIDSignInUIDelegate
  
  // BEGIN: GIDSignInDelegate
  
  func signIn(user: GIDGoogleUser?) {
    for emitter in RNGoogleSignIn.emitters {
      if (emitter.isObserving()) {
        emitter.sendEvent(withName: "signIn", body: RNGoogleSignIn.userToJSON(user))
      }
    }
  }
  
  func signInError(error: Error?) {
    for emitter in RNGoogleSignIn.emitters {
      if (emitter.isObserving()) {
        emitter.sendEvent(withName: "signInError", body: [
          "description": error?.localizedDescription ?? "",
        ])
      }
    }
  }
  
  func disconnect(user: GIDGoogleUser?) {
    for emitter in RNGoogleSignIn.emitters {
      if (emitter.isObserving()) {
        emitter.sendEvent(withName: "disconnect", body: RNGoogleSignIn.userToJSON(user))
      }
    }
  }
  
  func disconnectError(error: Error?) {
    for emitter in RNGoogleSignIn.emitters {
      if (emitter.isObserving()) {
        emitter.sendEvent(withName: "disconnectError", body: [
          "description": error?.localizedDescription ?? "",
          ])
      }
    }
  }
  
  func dispatch(error: Error?) {
    for emitter in RNGoogleSignIn.emitters {
      if (emitter.isObserving()) {
        emitter.sendEvent(withName: "dispatch", body: [
          "description": error?.localizedDescription ?? "",
        ])
      }
    }
  }
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
    if (error == nil && user != nil) {
      self.signIn(user: user)
    } else {
      self.signInError(error: error)
    }
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser?, withError error: Error?) {
    if (error == nil) {
      self.disconnect(user: user)
    } else {
      self.disconnectError(error: error)
    }
  }
  
  // END: GIDSignInDelegate

}
