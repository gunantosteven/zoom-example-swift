//
//  AppDelegate.swift
//  zoomexample
//
//  Created by GBU on 17/03/20.
//  Copyright © 2020 Spinergy. All rights reserved.
//

import UIKit
import MobileRTC

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var kSDKAppKey = "JwiCvNZfzLMZhTF6I0ktdEgquSVphbuzEBbm"
    var kSDKAppSecret = "PNjhQcGByfU7NcmP0YcanuEL0oPKvCQRQ2IW"
    var kSDKDomain = "zoom.us"
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let mobileRTCSDKInitContext = MobileRTCSDKInitContext.init()
        mobileRTCSDKInitContext.domain = kSDKDomain
        mobileRTCSDKInitContext.enableLog = true
        MobileRTC.shared().initialize(mobileRTCSDKInitContext)
        
        print("MobileRTC Version : ", MobileRTC.shared().mobileRTCVersion() ?? "")
        
        if let authService = MobileRTC.shared().getAuthService() {
            authService.delegate = self
            
            authService.clientKey = kSDKAppKey
            authService.clientSecret = kSDKAppSecret
            
            authService.sdkAuth()
        }
        
        // set root
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
//        self.window?.makeKeyAndVisible()
//        self.window?.rootViewController = vc
        
        return true
    }
}

extension AppDelegate : MobileRTCAuthDelegate {
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        if returnValue != MobileRTCAuthError_Success {
            print("SDK authentication failed, error code: " + returnValue.rawValue.description)
        }
    }
}

