//
//  AppDelegate.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/6/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var firstRun: Bool?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
//                let realm = try! Realm()
//                try! realm.write {
//                    print("Deleted all")
//                  realm.deleteAll()
//                }
        //
        //        Messaging.messaging().delegate = self
        //        requestPushNotificationPermission()
        
        firstRunCheck()
        
        //        application.registerForRemoteNotifications()
        
        LocationManager.shared.startUpdating()
        
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
    
    //MARK: - FirstRun
    private func firstRunCheck() {
        
        firstRun = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstRun! {
            
            //            let status = Status.allCases.map { $0.rawValue }
            
            //            userDefaults.set(status, forKey: kSTATUS)
            userDefaults.set(true, forKey: kFIRSTRUN)
            
            userDefaults.synchronize()
        }
    }
    
    
}

