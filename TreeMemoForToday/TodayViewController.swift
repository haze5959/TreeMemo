//
//  TodayViewController.swift
//  TreeMemoForToday
//
//  Created by OGyu kwon on 2020/06/18.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import UIKit
import SwiftUI
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    let hostingController = UIHostingController(rootView: ContentView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        TreeMemoState.shared.initTreeData()
        self.addPopup(self.hostingController)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 400) : maxSize
        self.hostingController.view.frame.size = preferredContentSize
    }
    
    /**
     addSubview
     */
    func addPopup(_ child: UIViewController, frame: CGRect? = nil) {
        self.addChild(child)
        
        if let frame = frame {
            child.view.frame = frame
        } else {
            child.view.frame = self.view.frame
        }
        
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /**
     removeFromSuperview
     */
    func removePopup() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
