//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-10.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // This is to accomodate Facebook login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // This is to accomodate Facebook login
        FBSDKAppEvents.activateApp()
    }

    // This is to accomodate Facebook login
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
     }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    

}

