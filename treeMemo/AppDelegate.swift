//
//  AppDelegate.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/19.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit
import CloudKit
import Network

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        TreeMemoState.shared.initTreeData()
        self.networkCheckStart()
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        CloudManager.shared.store.synchronize()
    }
    
    func networkCheckStart() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            TreeMemoState.shared.networkStatus = path.status
        }
        
        monitor.start(queue: .global(qos: .background))
    }
    
    enum KeyCommand {
        case save
        case cancel
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Save", action: #selector(handleKeyCommand(sender:)), input: "s", modifierFlags: .command, propertyList: KeyCommand.save),
            
            UIKeyCommand(title: "Cancel", action: #selector(handleKeyCommand(sender:)), input: "q", modifierFlags: .command, propertyList: KeyCommand.cancel)
        ]
    }
    
    @objc func handleKeyCommand(sender: UIKeyCommand) {
        if let command = sender.propertyList as? KeyCommand {
            NotificationCenter.default.post(name: .init("keyCommand"), object: command)
        }
    }
}

