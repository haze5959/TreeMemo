//
//  TreeNodeView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/21.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

// MARK: TreeNode
struct TreeNode: View {
    var treeData: TreeModel
    
    var body: some View {
        self.getCellView(data: self.treeData)
    }
    
    func getCellView(data: TreeModel) -> some View {
        switch data.value {
        case .none:
            return AnyView(
                HStack {
                    Text(data.title)
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Type Select!")
                            .padding()
                    })
                }
            )
        case .child(let key):
            return AnyView(
                NavigationLink(destination: BodyView(title: data.title,
                                                     treeDataKey: key,
                                                     depth: TreeMemoState.shared.treeHierarchy.count + 1)) {
                                                        HStack {
                                                            Text(data.title)
                                                            Spacer()
                                                            Image(systemName: "folder")
                                                        }
                }
            )
        case .text(let val):
            return AnyView(
                HStack {
                    Text(data.title)
                    Spacer()
                    Text(val)
                }
            )
        case .longText:
            return AnyView(
                HStack {
                    Text(data.title)
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Detail")
                            .padding()
                    })
                }
            )
        case .int(let val):
            return AnyView(
                HStack {
                    Text(data.title)
                    Spacer()
                    Text("\(val)")
                }
            )
        case .date(let val):
            return AnyView(
                HStack {
                    Text(data.title)
                    Spacer()
                    Text("\(val)")
                }
            )
        case .toggle(let val):
            return AnyView(
                HStack {
                    Text(data.title)
                    Spacer()
                    Text("\(val.description)")
                }
            )
        }
    }
}

// MARK: Preview
struct TreeNode_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            TreeNode(treeData: TreeModel(title: "none"))
            TreeNode(treeData: TreeModel(title: "child", value: .child(key: 0)))
            TreeNode(treeData: TreeModel(title: "date", value: .date(val: Date())))
            TreeNode(treeData: TreeModel(title: "int", value: .int(val: 22)))
            TreeNode(treeData: TreeModel(title: "text", value: .text(val: "텍스트")))
            TreeNode(treeData: TreeModel(title: "longText", value: .longText(val: "긴 텍스트")))
            TreeNode(treeData: TreeModel(title: "toggle", value: .toggle(val: true)))
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
