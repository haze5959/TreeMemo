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
    @State var showingAlert = false
    
    @Environment(\.presentationMode) var presentation
    let watchDelay = DispatchTimeInterval.milliseconds(500)   // 뷰 관련 작업 중 바로하면 안먹히는게 있어서 딜레이 적용
    
    var body: some View {
        self.getCellView(data: self.treeData)
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
        return Text(data.title)
            .padding()
    }
    
    func showAlertAboutNotSupport() {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
            print("워치에서는 설정 불가")
            self.showingAlert = true
        }
    }
    
    func getCellView(data: TreeModel) -> some View {
        switch data.value {
        case .new:
            return AnyView(
                NavigationLink(
                    destination: WatchInputFieldView(completeHandler: { (text) in
                        var tempData = self.treeData
                        tempData.title = text
                        tempData.value = .none
                        TreeMemoState.shared.treeData[self.treeData.key]!.append(tempData)
                    })) {
                        HStack {
                            self.getTitleView(data: data)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                        }
                }
            )
        case .none:
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.showingView = true
                    }, label: {
                        Image(systemName: "plus.square")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                    }).actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Type Select"), message: Text("Please select memo type or folder."), buttons: [
                            .default(Text("Image"), action: {
                                self.showAlertAboutNotSupport()
                            }),
                            .default(Text("On/Off"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = self.treeData
                                    tempData.value = .toggle(val: false)
                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                }
                            }),
                            .default(Text("Date"), action: {
                                self.showAlertAboutNotSupport()
                            }),
                            .default(Text("Long Text"), action: {
                                self.showAlertAboutNotSupport()
                            }),
                            .default(Text("Text"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = self.treeData
                                    tempData.value = .text(val: "")
                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                }
                            }),
                            .default(Text("Number"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = self.treeData
                                    tempData.value = .int(val: 0)
                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                }
                            }),
                            .default(Text("Folder"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = self.treeData
                                    let newChildKey = UUID()
                                    tempData.value = .child(key: newChildKey)
                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                    let subTreeData = [TreeModel]()
                                    TreeMemoState.shared.treeData.updateValue(subTreeData, forKey: newChildKey)
                                }
                            }),
                        ])
                    }.alert(isPresented: self.$showingAlert) {
                        Alert(title: Text("This feature is not supported on Apple Watch."))
                    }
                }
            )
        case .child(let key):
            return AnyView(
                NavigationLink(destination: BodyView(title: data.title,
                                                     treeDataKey: key)) {
                                                        HStack {
                                                            self.getTitleView(data: data)
                                                            Spacer()
                                                            Image(systemName: "folder")
                                                                .padding()
                                                        }
                }
            )
        case .text(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Text(val.count > 0 ? val : "...")
                    .fixedSize(horizontal: false, vertical: true)
                        .padding()
                }
            )
        case .longText(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Image(systemName: "doc.plaintext")
                    .padding()
                }
            )
        case .int(let val):
            return AnyView(
                Text("\(val)")
            )
        case .date(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Text("날짜 어케하지")
                }
            )
        case .toggle(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Text("토글 어케하지")
                }
            )
        case .image(let imagePath):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        print("이미지 수정 불가")
                    }, label: {
                        Text("이미지 어케 넣냐")
                    })
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
            TreeNode(treeData: TreeModel(title: "date", value: .date(val: TreeDateType(date: Date(), type: 1)), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "int", value: .int(val: 22), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "text", value: .text(val: "텍스트텍스트텍스트텍스 트텍스트텍스트텍스트텍스트텍스트텍스트텍스 트텍스트텍스트텍스 트텍스트텍스트텍스트텍스트텍스트"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "longText", value: .longText(val: "긴 텍스트"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "toggle", value: .toggle(val: true), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "image", value: .image(imagePath: "nono"), key:RootKey, index: 0))
            
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
