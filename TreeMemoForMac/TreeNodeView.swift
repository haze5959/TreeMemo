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
    @State var showingView = false
    
    var body: some View {
        self.getCellView(data: self.treeData)
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
        return Button(action: {
            // TODO:
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
                        // TODO:
                    }, label: {
                        Image(systemName: "plus.circle")
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
                        self.showingView.toggle()
                    }, label: {
                        Image(systemName: "plus.square")
                            .padding()
                    })
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
                                                        }
                }
            )
        case .text(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        // TODO:
                    }, label: {
                        Text(val.count > 0 ? val : "...")
                            .minimumScaleFactor(0.8)
                            .lineLimit(2)
                    })
                        .padding()
                }
            )
        case .longText(let recordName):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        //상세 내용 보기 화면
                        // TODO:
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
                           // TODO:
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
                        self.showingView.toggle()
                    }, label: {
                        Text("// TODO:")
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
                        //상세 내용 보기 화면
                        if false {
                            // TODO:
                        } else {
                            if recordName.count == 0 {
                                self.showingView.toggle()
                            } else {
                                CloudManager
                                    .shared
                                    .getData(recordType: "Image",
                                             recordName: recordName) { (result) in
                                                switch result {
                                                case .success(let records):
                                                    guard records.count > 0, let imgData = records[0].value(forKey: "data") as? Data else {
                                                        print("No image data!")
                                                        return
                                                    }
                                                    
                                                    let newRecordName = records[0].recordID.recordName
                                                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                                    
                                                    let newPath = "\(documentsPath)/\(newRecordName).png"
                                                    do {
                                                        try imgData.write(to: URL(fileURLWithPath: newPath))
                                                        
                                                        // 데이터가 안바뀌면 리스트도 업데이트 안되기 때문에 다음과 같이 처리
                                                        DispatchQueue.main.async {
                                                            var tempData = data
                                                            tempData.value = .image(recordName: "")
                                                            TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                                tempData.value = .image(recordName: newRecordName)
                                                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                                            }
                                                        }
                                                    } catch {
                                                        print(error.localizedDescription)
                                                    }
                                                case .failure(let error):
                                                    print(error.localizedDescription)
                                                }
                                }
                            }
                        }
                    }, label: {
                        Text("// TODO:")
                    })
                }
            )
        case .link(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.showingView.toggle()
                    }, label: {
                        Image(systemName: "link")
                            .padding()
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
            TreeNode(treeData: TreeModel(title: "longText", value: .longText(recordName: "2123"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "toggle", value: .toggle(val: true), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "image", value: .image(recordName: "12313"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "link", value: .link(val: "www.naver.com"), key:RootKey, index: 0))
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
