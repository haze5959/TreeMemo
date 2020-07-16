//
//  BodyView.swift
//  TreeMemoForWatch Extension
//
//  Created by OGyu kwon on 2020/02/19.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

struct BodyView: View {
    let title: String?
    let treeDataKey: UUID
        
    @ObservedObject var treeMemoState = TreeMemoState.shared
    
    var body: some View {
        List {
            ForEach(self.treeMemoState.getTreeData(key: self.treeDataKey)) { treeData in
                TreeNode(treeData: treeData)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationBarTitle(self.title ?? "Tree Memo")
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BodyView(title: "TEST", treeDataKey: RootKey)
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
