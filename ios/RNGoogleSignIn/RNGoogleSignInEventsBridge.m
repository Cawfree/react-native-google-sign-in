//
//  RNGoogleSignInEventsBridge.m
//
//  Created by Joon Ho Cho on 1/17/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTBridgeModule.h>)
  #import <React/RCTBridgeModule.h>
#elif __has_include("RCTBridgeModule.h")
  #import "RCTBridgeModule.h"
#else
  #import "React/RCTBridgeModule.h"
#endif

#if __has_include(<React/RCTEventEmitter.h>)
  #import <React/RCTEventEmitter.h>
#elif __has_include("RCTEventEmitter.h")
  #import "RCTEventEmitter.h"
#else
  #import "React/RCTEventEmitter.h"
#endif

@interface RCT_EXTERN_MODULE(RNGoogleSignInEvents, RCTEventEmitter)

@end
