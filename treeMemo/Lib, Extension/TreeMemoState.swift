//
//  TreeMemoEnvironment.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/26.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class TreeMemoState: ObservableObject {
    static let shared = TreeMemoState()
    
    @Published var treeHierarchy = [String]()
    @State var isEdit = false
    var treeData = mockUpVal
}
