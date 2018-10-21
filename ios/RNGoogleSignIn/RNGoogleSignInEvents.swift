//
//  RNGoogleSignInEvents.swift
//
//  Created by Joon Ho Cho on 1/17/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation

@objc(RNGoogleSignInEvents)
class RNGoogleSignInEvents: RCTEventEmitter {

  // TODO: Externalize.
  var observing = false

  override init() {
    super.init()
    RNGoogleSignIn.emitters.append(self)
  }

  // TODO: Use allEvents
  override func supportedEvents() -> [String]! {
    return ["signIn", "signInError", "disconnect", "disconnectError", "dispatch"]
  }

  override func startObserving() {
    observing = true
  }

  override func stopObserving() {
    observing = false
  }

  public func isObserving() -> Bool! {
    return self.observing
  }

}
