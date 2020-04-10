//
//  AppDelegate.swift
//  TreeMemoForMac
//
//  Created by OGyu kwon on 2020/03/17.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    let statusItem:NSStatusItem  = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        TreeMemoState.shared.initTreeData()
        self.setUpStatusItem()
        self.setUpPopoverVC()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        CloudManager.shared.store.synchronize()
    }
}

extension AppDelegate {
    func setUpStatusItem() {
        //get instance statusBar and set Btn
        if let button = self.statusItem.button {
//            button.image = #imageLiteral(resourceName: "TestImg")
            button.action = #selector(togglePopover(_:))
        }
    }
    
    func setUpPopoverVC() {
        let contentView = ContentView().environmentObject(EnvironmentState())
        self.popover.contentViewController = NSHostingController(rootView: contentView)
    }
    
    // MARK: StatusBar Btn Evnet
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            self.popover.performClose(sender)
        } else {
            if let button = self.statusItem.button {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}

