//
//  WatchAlertState.swift
//  TreeMemoForWatch Extension
//
//  Created by OQ on 2020/03/18.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

enum ActiveAlert {
    case notSupport
    case notPared
}

class WatchAlertState: ObservableObject {
    static let shared = WatchAlertState()
    @Published var showAlert = false
    var activeAlert: ActiveAlert = .notSupport
    var paringRetryCount = 0
    
    let notSupportText = "This feature is not supported on Apple Watch."
    let notParedText = "Can't pair with the iPhone app. Please wait for a moment or restart the iPhone app."
    let waitParingText = "Paring with a iPhone. please wait a moment."
    
    func getParingText() -> String {
        if self.paringRetryCount == 0 {
            self.paringRetryCount += 1
            return self.waitParingText
        } else {
            return self.notParedText
        }
    }
    
    func show(showCase: ActiveAlert) {
        self.activeAlert = showCase
        self.showAlert = true
    }
    
    func hide() {
        self.showAlert = false
    }
}
