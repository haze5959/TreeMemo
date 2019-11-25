//
//  TreeNodeView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/21.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct TreeNode: View {
    var treeData: RootTreeModel
    @State var isConnectedTreeNode: Bool
    
    var body: some View {
        VStack {
            if self.isConnectedTreeNode {
                TreeNode(treeData: RootTreeModel(), isConnectedTreeNode: false)
            }
            
            Button(action: {
                self.isConnectedTreeNode = true
            }, label: {
                Text("OpenedNode")
                    .padding()
            }).frame(width: 150)
        }
    }
}

struct OpenedTreeNode: View {
    var action: () -> Void
    var body: some View {
        Button(action: action, label: {
            Text("ClosedNode")
                .padding()
        }).frame(width: 150)
    }
}

// MARK: Preview
struct TreeNode_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            TreeNode(treeData: RootTreeModel(), isConnectedTreeNode: false)
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
