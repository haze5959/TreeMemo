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
    var hostingController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        let envi = EnvironmentProperty()
        envi.todayVC = self
        let contentView = ContentView().environmentObject(envi)
        self.hostingController = UIHostingController(rootView: contentView)
        self.hostingController?.view.backgroundColor = .clear
        
        TreeMemoState.shared.initTreeData()
        self.addPopup(self.hostingController!)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 500) : maxSize
        self.hostingController?.view.frame.size = preferredContentSize
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
