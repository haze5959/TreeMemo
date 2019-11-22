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
    @Published var items = [TreeNode]()
    var body: some View {
        HStack {
            ForEach(0..<self.items.capacity) { index in
                self.items.
            }
            
            Button(action: {
                self.
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
            OpenedNode {
                print("OpenedNode")
            }
            
            ClosedNode {
                print("ClosedNode")
            }
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
