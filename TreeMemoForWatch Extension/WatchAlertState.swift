//
//  WatchAlertState.swift
//  TreeMemoForWatch Extension
//
//  Created by OQ on 2020/03/18.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

class WatchAlertState: ObservableObject {
    static let shared = WatchAlertState()
    @Published var notSupport = false
    @Published var notPared = false
    
    let notSupportText = "This feature is not supported on Apple Watch."
    let notParedText = "Can't pair with the iPhone app. Please open or restart the iPhone app."
}
