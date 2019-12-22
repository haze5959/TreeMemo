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
    
    @State var pickerType: UIImagePickerController.SourceType = .photoLibrary
    @State var showImagePicker: Bool = false
    @State var image: Image? = nil
    
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
                    Button(action: {
                        self.showingView.toggle()
                    }, label: {
                        Image(systemName: "plus.square")    //
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                    }).actionSheet(isPresented: self.$showingView) {
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
                            .default(Text("Long Text"), action: {
                                var tempData = self.treeData
                                tempData.value = .longText(val: "...")
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("Date"), action: {
                                var tempData = self.treeData
                                tempData.value = .date(val: TreeDateType(date: Date(), type: UIDatePicker.Mode.date.rawValue))
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("On/Off"), action: {
                                var tempData = self.treeData
                                tempData.value = .toggle(val: false)
                                TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            }),
                            .default(Text("Image"), action: {
                                var tempData = self.treeData
                                tempData.value = .image(imagePath: "")
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
                                                text: val,
                                                placeHolder: val,
                                                doneCompletion: { (text) in
                                                    var tempData = data
                                                    tempData.value = .text(val: text)
                                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                            })
                    }, label: {
                        Text(val)
                            .fixedSize(horizontal: false, vertical: true)
                    })
                        .padding()
                }
            )
        case .longText(let val):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        //상세 내용 보기 화면
                        ViewModel().showDetailView(title: data.title, text: val) { (text) in
                            var tempData = data
                            tempData.value = .longText(val: text)
                            TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                        }
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
                    Button(action: {
                        self.showingView.toggle()
                    }, label: {
                        Text("\(ViewModel().getDateString(treeDate: val))")
                    }).actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Type Select"), message: Text("Please select date type."), buttons: [
                            .default(Text("Date And Time"), action: {
                                let pickerView = OQPickerView.sharedInstance
                                pickerView.showDate(title: "Select Date", datePickerMode: UIDatePicker.Mode.dateAndTime) { (date) in
                                    var tempData = data
                                    tempData.value = .date(val: TreeDateType(date: date, type: UIDatePicker.Mode.dateAndTime.rawValue))
                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                }
                                pickerView.overrideUserInterfaceStyle = .light
                                
                                UIApplication.shared.windows[0].rootViewController?.view.addSubview(pickerView)
                            }),
                            .default(Text("Date"), action: {
                                let pickerView = OQPickerView.sharedInstance
                                pickerView.showDate(title: "Select Date", datePickerMode: UIDatePicker.Mode.date) { (date) in
                                    var tempData = data
                                    tempData.value = .date(val: TreeDateType(date: date, type: UIDatePicker.Mode.date.rawValue))
                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                }
                                pickerView.overrideUserInterfaceStyle = .light
                                
                                UIApplication.shared.windows[0].rootViewController?.view.addSubview(pickerView)
                            }),
                            .default(Text("Time"), action: {
                                let pickerView = OQPickerView.sharedInstance
                                pickerView.showDate(title: "Select Date", datePickerMode: UIDatePicker.Mode.time) { (date) in
                                    var tempData = data
                                    tempData.value = .date(val: TreeDateType(date: date, type: UIDatePicker.Mode.time.rawValue))
                                    TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                                }
                                pickerView.overrideUserInterfaceStyle = .light
                                
                                UIApplication.shared.windows[0].rootViewController?.view.addSubview(pickerView)
                            }),
                            .cancel()
                        ])
                    }
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
        case .image(let imagePath):
            return AnyView(
                HStack {
                    self.getTitleView(data: data)
                    Spacer()
                    Button(action: {
                        //상세 내용 보기 화면
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let path = "\(documentsPath)/\(imagePath)"
                        if let image = UIImage(contentsOfFile: path) {
//                            self.image = ViewModel().getImage(path: imagePath)
                            ViewModel().showImageView(image: Image(uiImage: image))
                        } else {
                            self.showingView.toggle()
                        }
                    }, label: {
                        { self.image ?? ViewModel().getImage(path: imagePath) }()
                        .resizable()
                        .scaledToFit()
                    }).actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Type Select"), message: Text("Please select Image Picker type."), buttons: [
                            .default(Text("Camera"), action: {
                                self.pickerType = UIImagePickerController.SourceType.camera
                                self.showImagePicker.toggle()
                            }),
                            .default(Text("Album"), action: {
                                self.pickerType = UIImagePickerController.SourceType.photoLibrary
                                self.showImagePicker.toggle()
                            }),
                            .cancel()
                        ])
                    }.sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: self.$image, pickerType: self.pickerType) { (path) in
                            var tempData = self.treeData
                            tempData.value = .image(imagePath: path)
                            TreeMemoState.shared.treeData[self.treeData.key]![self.treeData.index] = tempData
                        }
                    }
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
