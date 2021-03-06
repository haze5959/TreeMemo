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
    
    let watchDelay = DispatchTimeInterval.milliseconds(500)   // 뷰 관련 작업 중 바로하면 안먹히는게 있어서 딜레이 적용
    
    var body: some View {
        self.getCellView(data: self.treeData)
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
        return Text(data.title)
    }
    
    func getDateString(treeDate: TreeDateType) -> some View {
        let date = treeDate.date
        let type = treeDate.type // 0: time, 1: date, 2: dateAndTime
        
        let dateFormatter = DateFormatter()
        if type == 2 {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
        } else if type == 1 {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        } else if type == DateTypeDDay {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return AnyView(
                HStack {
                    Text("D-Day ")
                        .font(Font.system(size: 10, weight: .thin, design: .rounded))
                    Text(date.relativeDaysFromToday())
                }
            )
        } else if type == DateTypeDDayIncludeFirstDay {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return AnyView(
                HStack {
                    Text("D-Day ")
                    .font(Font.system(size: 10, weight: .thin, design: .rounded))
                    Text(date.relativeDaysFromToday(includeFirstDay: true))
                }
            )
        } else {    //time
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        
        return AnyView(Text(dateFormatter.string(from: date)))
    }
    
    func showAlertAboutNotSupport() {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
            print("워치에서는 설정 불가")
            WatchAlertState.shared.show(showCase: .notSupport)
        }
    }
    
    func getCellView(data: TreeModel) -> some View {
        switch data.value {
        case .new:
            return AnyView(
                NavigationLink(
                    destination: WatchInputFieldView(desc: "Input memo title.",
                                                     completeHandler: { (text) in
                                                        var tempData = data
                                                        tempData.title = text
                                                        tempData.value = .none
                                                        TreeMemoState.shared.treeData[data.key]!.append(tempData)
                    })) {
                        HStack {
                            self.getTitleView(data: data)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
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
                    }).actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Type Select"), message: Text("Please select memo type or folder."), buttons: [
                            .default(Text("On/Off"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = data
                                    tempData.value = .toggle(val: false)
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                }
                            }),
                            .default(Text("Text"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = data
                                    tempData.value = .text(val: "")
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                }
                            }),
                            .default(Text("Number"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = data
                                    tempData.value = .int(val: 0)
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                }
                            }),
                            .default(Text("Folder"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.watchDelay) {
                                    var tempData = data
                                    let newChildKey = UUID()
                                    tempData.value = .child(key: newChildKey)
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                    let subTreeData = [TreeModel]()
                                    TreeMemoState.shared.treeData.updateValue(subTreeData, forKey: newChildKey)
                                }
                            }),
                        ])
                    }
                }
            )
        case .child(let key):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    NavigationLink(destination: BodyView(title: data.title,
                                                         treeDataKey: key)) {
                                                            Image(systemName: "folder")
                    }
                }
            )
        case .text(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    NavigationLink(
                        destination: WatchInputFieldView(desc: "Input text.",
                                                         completeHandler: { (text) in
                                                            var tempData = data
                                                            tempData.value = .text(val: text)
                                                            TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                        })) {
                            Text(val.count > 0 ? val : "...")
                                .minimumScaleFactor(0.7)
                                .lineLimit(2)
                    }
                }
            )
        case .longText(let recordName):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    NavigationLink(
                        destination:
                        WatchLongTextView(title: data.title, recordName: recordName)
                    ) {
                        Image(systemName: "doc.plaintext")
                    }
                }
            )
        case .int(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    NavigationLink(
                        destination: WatchInputNumberView(tempInt: Float(val) ,completeHandler: { (number) in
                            var tempData = data
                            tempData.value = .int(val: number)
                            TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                        })) {
                            Text("\(val)")
                    }
                }
            )
        case .date(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    self.getDateString(treeDate: val)
                }
            )
        case .toggle(let val):
            return AnyView(
                HStack {
                    Button(action: {
                        var tempData = data
                        tempData.value = .toggle(val: !val)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                    }, label: {
                        self.getTitleView(data: data)
                        Spacer()
                        if val {
                            Image(systemName: "lightbulb.fill")
                        } else {
                            Image(systemName: "lightbulb.slash")
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
                        self.showAlertAboutNotSupport()
                    }, label: {
                        Image(systemName: "photo")
                    })
                }
            )
        case .link:
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        self.showAlertAboutNotSupport()
                    }, label: {
                        Image(systemName: "link")
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
            TreeNode(treeData: TreeModel(title: "longText", value: .longText(recordName: "12313"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "toggle", value: .toggle(val: true), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "image", value: .image(recordName: "12313"), key:RootKey, index: 0))
            
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
