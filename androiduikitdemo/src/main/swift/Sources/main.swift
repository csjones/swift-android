//
//  main.swift
//  AndroidUIKit
//
//  Created by Carlos Duclos on 7/13/18.
//

import Foundation

#if os(iOS)

import UIKit

UIApplicationMain(0, nil, nil, NSStringFromClass(AppDelegate.self))

#else

import java_swift
import java_lang
import java_util
import Android

/// Needs to be implemented by app.
@_silgen_name("SwiftAndroidMainApplication")
public func SwiftAndroidMainApplication() -> SwiftApplication.Type {
    
    NSLog("\(#function)")
    
    UIApplication.shared.delegate = AppDelegate()
    
    return AndroidUIKitApplication.self
}

/// Needs to be implemented by app.
@_silgen_name("SwiftAndroidMainActivity")
public func SwiftAndroidMainActivity() -> SwiftSupportAppCompatActivity.Type {
    
    NSLog("\(#function)")
    
    return AndroidUIKitMainActivity.self
}

#endif
