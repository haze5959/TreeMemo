//
//  EnvironmentState.swift
//  treeMemo
//
//  Created by OQ on 2020/01/26.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import Foundation

class EnvironmentState: ObservableObject {
    @Published var isEdit = false
    @Published var openSideMenu = false
}
