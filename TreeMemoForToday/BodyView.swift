//
//  BodyView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

struct BodyView: View {    
    let treeDataKey: UUID

    @State private var subscriptions = Set<AnyCancellable>()
    @ObservedObject var treeMemoState = TreeMemoState.shared
    
    var body: some View {
        List {
            ForEach(self.treeMemoState.getTreeData(key: self.treeDataKey)) { treeData in
                TreeNode(treeData: treeData)
                    .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
