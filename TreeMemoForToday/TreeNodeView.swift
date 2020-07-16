//
//  TreeNodeView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/21.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI
import CloudKit

// MARK: TreeNode
struct TreeNode: View {
    @EnvironmentObject var envi: EnvironmentProperty
    var treeData: TreeModel
    
    var body: some View {
        self.getCellView(data: self.treeData)
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
        return Button(action: {
            self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
        }, label: {
            Text(data.title)
        }).padding()
    }
    
    func getCellView(data: TreeModel) -> some View {
        switch data.value {
        case .new:  // 투데이 익스텐션에서는 7개 이상 넘어갔을 때 컷팅용도로 쓰인다.
            return AnyView(
                HStack {
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        Image(systemName: "ellipsis")
                            .padding()
                    })
                    Spacer()
                }
            )
        case .none:
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        Image(systemName: "plus.square")
                            .padding()
                    })
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
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        Text(val.count > 0 ? val : "...")
                            .minimumScaleFactor(0.8)
                            .lineLimit(2)
                    }).padding()
                }
            )
        case .longText(_):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        Image(systemName: "doc.plaintext")
                            .padding()
                    })
                }
            )
        case .int(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        Text("\(val)").minimumScaleFactor(0.8)
                    }).padding()
                }
            )
        case .date(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        ViewModel().getDateString(treeDate: val)
                            .padding()
                    })
                }
            )
        case .toggle(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        if val {
                            Image(systemName: "lightbulb.fill").padding()
                        } else {
                            Image(systemName: "lightbulb.slash").padding()
                        }
                    })
                }
            )
        case .image:
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: "treeMemo://")!, completionHandler: nil)
                    }, label: {
                        Image(systemName: "photo")
                            .padding()
                    })
                }
            )
        case .link(let url):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.envi.todayVC?.extensionContext?.open(URL(string: url)!, completionHandler: nil)
                    }, label: {
                        Image(systemName: "link")
                            .padding()
                    })
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
