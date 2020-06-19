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
    var treeData: TreeModel
    
    var body: some View {
        self.getCellView(data: self.treeData)
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
        return Button(action: {
        }, label: {
            Text(data.title)
        })
            .padding()
    }
    
    func getCellView(data: TreeModel) -> some View {
        switch data.value {
        case .new:
            return AnyView(
                HStack {
                    Spacer()
                    Button(action: {
                    }, label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
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
                    }, label: {
                        Image(systemName: "plus.square")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                    })
                }
            )
        case .child(let key):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Image(systemName: "folder")
                }
            )
        case .text(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
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
                        //상세 내용 보기 화면
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
                    Stepper(onIncrement: {
                        var tempData = data
                        tempData.value = .int(val: val + 1)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                    }, onDecrement: {
                        var tempData = data
                        tempData.value = .int(val: val - 1)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                    }) {
                        Button(action: {
                        }, label: {
                            Text("\(val)")
                        })
                            .padding()
                    }
                }
            )
        case .date(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                    }, label: {
                        Text("\(ViewModel().getDateString(treeDate: val))")
                    })
                }
            )
        case .toggle(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    OQToggleView(model: ToggleModel(isOn: val, action: { (isOn) in
                        var tempData = data
                        tempData.value = .toggle(val: isOn)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                    })).padding()
                }
            )
        case .image(let recordName):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                    }, label: {
                        ViewModel().getImage(name: recordName)
                    })
                }
            )
        case .link(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                    }, label: {
                        Image(systemName: "link")
                            .padding()
                    })
                }
            )
        }
    }
}
