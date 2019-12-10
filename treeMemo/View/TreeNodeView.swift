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
    @State var showingView = false
    
    var body: some View {
        self.getCellView(data: self.treeData)
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
        return Button(action: {
            UIApplication.shared.windows[0]
                .rootViewController?
                .showTextFieldAlert(title: "Input Title",
                                    placeHolder: data.title,
                                    doneCompletion: { (text) in
                                        var tempData = data
                                        tempData.title = text
                                        TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                })
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
                        UIApplication.shared.windows[0]
                            .rootViewController?
                            .showTextFieldAlert(title: "Input Title",
                                                placeHolder: "Input memo title...",
                                                doneCompletion: { (text) in
                                                    var tempData = self.treeData
                                                    tempData.title = text
                                                    tempData.value = .none
                                                    TreeMemoState.shared.treeData[self.treeData.key]!.append(tempData)
                            })
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
                    Button("Type Select!") {
                        self.showingView.toggle()
                    }.actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Type Select"), message: Text("Please select memo type."), buttons: [
                            .default(Text("Folder"), action: {
                                var tempData = self.treeData
                                tempData.value = .child(key: UUID())
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("Number"), action: {
                                var tempData = self.treeData
                                tempData.value = .int(val: 0)
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("Text"), action: {
                                var tempData = self.treeData
                                tempData.value = .text(val: "...")
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("longText"), action: {
                                var tempData = self.treeData
                                tempData.value = .longText(val: "...")
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("Date"), action: {
                                var tempData = self.treeData
                                tempData.value = .date(val: Date())
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("On/Off"), action: {
                                var tempData = self.treeData
                                tempData.value = .toggle(val: false)
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .cancel()
                        ])
                    }
                }
            )
        case .child(let key):
            return AnyView(
                NavigationLink(destination: BodyView(title: data.title,
                                                     treeDataKey: key,
                                                     depth: TreeMemoState.shared.treeHierarchy.count + 1)) {
                                                        HStack {
                                                            self.getTitleView(data: data)
                                                            Spacer()
                                                            Image(systemName: "folder")
                                                        }
                }
            )
        case .text(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        UIApplication.shared.windows[0]
                            .rootViewController?
                            .showTextFieldAlert(title: "Input Value",
                                                placeHolder: val,
                                                doneCompletion: { (text) in
                                                    var tempData = data
                                                    tempData.value = .text(val: text)
                                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            })
                    }, label: {
                        Text(val)
                    })
                        .padding()
                }
            )
        case .longText:
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
                        var tempData = self.treeData
                        tempData.value = .int(val: val + 1)
                        TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                    }, onDecrement: {
                        var tempData = self.treeData
                        tempData.value = .int(val: val - 1)
                        TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                    }) {
                        Button(action: {
                            UIApplication.shared.windows[0]
                                .rootViewController?
                                .showTextFieldAlert(title: "Input Value",
                                                    placeHolder: "\(val)",
                                    isNumberOnly: true,
                                    doneCompletion: { (text) in
                                        var tempData = data
                                        guard let intVal = Int(text) else {
                                            print("text not convert to int!: \(text)")
                                            return
                                        }
                                        tempData.value = .int(val: intVal)
                                        TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                })
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
                    Text("\(val)")
                }
            )
        case .toggle(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    OQToggleView(model: ToggleModel(isOn: val, action: { (isOn) in
                        var tempData = self.treeData
                        tempData.value = .toggle(val: isOn)
                        TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                    }))
                }
            )
        }
    }
}

// MARK: Preview
struct TreeNode_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            TreeNode(treeData: TreeModel(title: "new", value: .new, key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "none", key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "child", value: .child(key: UUID()), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "date", value: .date(val: Date()), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "int", value: .int(val: 22), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "text", value: .text(val: "텍스트"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "longText", value: .longText(val: "긴 텍스트"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "toggle", value: .toggle(val: true), key:RootKey, index: 0))
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
