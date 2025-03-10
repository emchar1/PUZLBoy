//
//  AppDelegate.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import UIKit
import FirebaseCore
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //Buffers all the AudioItems so there's no (noticeable) lag upon initialization 3/7/25.
        _ = AudioManager.shared
        
        
        
        // FIXME: - GoogleMobileAds is responsible for 20 MEMORY LEAKS in Instruments!!
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
            AdMobManager.eddiesiPhoneTestingDeviceID,
            AdMobManager.momsiPhoneTestingDeviceID,
            AdMobManager.dadsiPhoneTestingDeviceID,
            AdMobManager.momsiPadTestingDeviceID,
            AdMobManager.dadsiPadTestingDeviceID
        ]
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        
        
        return true
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

