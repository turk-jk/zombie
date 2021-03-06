//
//  AppDelegate.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setStateForUITesting()

        if googleKey == ""{
            fatalError("Add google key first")
        }
        return true
    }
    
    // set up envoirment for UI testing
    private func setStateForUITesting() {
        if ProcessInfo.processInfo.arguments.contains(st.UI_Testing.s){
            let hasLevelOfPain = ProcessInfo.processInfo.environment[st.hasLevelOfPain.s] == "YES"
            UserDefaults.standard.set(hasLevelOfPain, forKey: st.hasLevelOfPain.s)
        }
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

