//
//  SceneDelegate.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/6/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        autoLogin()
        
        restBudge()
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        restBudge()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        LocationManager.shared.startUpdating()
        restBudge()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        LocationManager.shared.stopUpdating()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        restBudge()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        LocationManager.shared.stopUpdating()
        restBudge()
    }
    
    //MARK: - Autologin
    func autoLogin() {
        
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil && userDefaults.object(forKey: kCURRENTUSER) != nil {
                
                DispatchQueue.main.async {
                    self.goToApp()
                }
            }
        })
    }
    
    //MARK: Go To App
    func goToApp() {
        
        print("Third Print")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId])
        
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        
        // setting root view controller to main app screen
        self.window?.rootViewController = mainView
    }
    
    
    private func restBudge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
}

//    func autoLogin() {
//        // AutoLogin
//        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
//
//            Auth.auth().removeStateDidChangeListener(self.authListener!)
//            print("First Print")
//            if user != nil {
//
//                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
//                    // there is a user logged in locally
//                    // skip log in screen and go to app
//
//                    if user != nil && userDefaults.object(forKey: kCURRENTUSER) != nil {
//                        print("Second Print")
//                        DispatchQueue.main.async {
//                            self.goToApp()
//
//                        }
//
//                    }
//                }
//            }
//
//        })
//    }
