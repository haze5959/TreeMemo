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
    
    let notSupportText = "This feature is not supported on Apple Watch."
    let notParedText = "Can't pair with the iPhone app. Please open or restart the iPhone app."
    
    func show(showCase: ActiveAlert) {
        self.activeAlert = showCase
        self.showAlert = true
    }
}
