//
//  AppDelegate.swift
//  Entradas
//
//  Created by Gustavo Aceredo on 30/01/17.
//  Copyright © 2017 Gustavo Aceredo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {

    var window: UIWindow?
    var databaseRef: FIRDatabaseReference!
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FIRApp.configure()
        
        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        
        return true
    }
   
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        // Google
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                          annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return true
        
        
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("User signed into google")
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print("User Signed Into Firebase")
            
            
            self.databaseRef = FIRDatabase.database().reference()
            
            self.databaseRef.child("user_profiles").child("\(user!.uid)/datos_usuarios/").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                if(snapshot == nil)
                {
                    self.databaseRef.child("user_profiles").child("\(user!.uid)/datos_usuarios/").child("name").setValue(user?.displayName)
                    self.databaseRef.child("user_profiles").child("\(user!.uid)/datos_usuarios/").child("email").setValue(user?.email)
                    
                }
                
            })
            
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        // Realiza cualquier operación cuando el usuario se desconecta de la aplicación aquí.
    }

    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

