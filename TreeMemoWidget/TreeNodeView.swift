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
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
//        let urlStr = "treeMemo://\(data.key)"
        let urlStr = "treeMemo://\(data.key)"
        return Link(data.title, destination: URL(string: urlStr)!).padding()
    }
    
    func getCellView(data: TreeModel) -> some View {
        switch data.value {
        case .new:  // 투데이 익스텐션에서는 7개 이상 넘어갔을 때 컷팅용도로 쓰인다.
            return AnyView(
                HStack {
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        Image(systemName: "ellipsis")
                            .padding()
                    }
                    Spacer()
                }
            )
        case .none:
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        Image(systemName: "plus.square")
                            .padding()
                    }
                }
            )
        case .child(let key):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        TreeMemoState.shared.treeDataKey = key
                        TreeMemoState.shared.previousTreeDataKey.append(data.key)
                    }, label: {
                        Image(systemName: "folder")
                            .padding()
                    })
                }
            )
        case .text(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        Text(val.count > 0 ? val : "...")
                            .minimumScaleFactor(0.8)
                            .lineLimit(2)
                    }.padding()
                }
            )
        case .longText(_):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        Image(systemName: "doc.plaintext")
                            .padding()
                    }
                }
            )
        case .int(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        Text("\(val)").minimumScaleFactor(0.8)
                    }.padding()
                }
            )
        case .date(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        ViewModel().getDateString(treeDate: val)
                            .padding()
                    }
                }
            )
        case .toggle(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        if val {
                            Image(systemName: "lightbulb.fill").padding()
                        } else {
                            Image(systemName: "lightbulb.slash").padding()
                        }
                    }
                }
            )
        case .image:
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: "treeMemo://\(data.key)")!) {
                        Image(systemName: "photo")
                            .padding()
                    }
                }
            )
        case .link(let url):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Link(destination: URL(string: url)!) {
                        Image(systemName: "link")
                            .padding()
                    }
                }
            )
        case .back:
            return AnyView(
                HStack {
                    Button(action: {
                        TreeMemoState.shared.historyBack()
                    }, label: {
                        Image(systemName: "arrow.left")
                            .padding()
                    })
                }
            )
        }
    }
}
