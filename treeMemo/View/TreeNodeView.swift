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
    
    @State var pickerType: UIImagePickerController.SourceType = .photoLibrary
    @State var showImagePicker: Bool = false
    
    var body: some View {
        self.getCellView(data: self.treeData)
            .frame(height: 50)
    }
    
    func getTitleView(data: TreeModel) -> some View {
        return Button(action: {
            UIApplication.shared.windows[0]
                .rootViewController?
                .showTextFieldAlert(title: "Input Title",
                                    text: data.title,
                                    placeHolder: data.title,
                                    doneCompletion: { (text) in
                                        var tempData = data
                                        tempData.title = text
                                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
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
                                                    var tempData = data
                                                    tempData.title = text
                                                    tempData.value = .none
                                                    TreeMemoState.shared.treeData[data.key]!.append(tempData)
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
                        Image(systemName: "plus.square")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                    }).actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Type Select"), message: Text("Please select memo type or folder."), buttons: [
                            .default(Text("Folder"), action: {
                                var tempData = data
                                let newChildKey = UUID()
                                tempData.value = .child(key: newChildKey)
                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                let subTreeData = [TreeModel]()
                                TreeMemoState.shared.treeData.updateValue(subTreeData, forKey: newChildKey)
                            }),
                            .default(Text("Number"), action: {
                                var tempData = data
                                tempData.value = .int(val: 0)
                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                            }),
                            .default(Text("Text"), action: {
                                var tempData = data
                                tempData.value = .text(val: "")
                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                            }),
                            .default(Text("Long Text"), action: {
                                let record = CKRecord(recordType: "Text")
                                record.setValue("", forKey: "text")
                                CloudManager.shared.makeData(record: record) { (result) in
                                    switch result {
                                    case .success(let record):
                                        let recordName = record.recordID.recordName
                                        var tempData = data
                                        tempData.value = .longText(recordName: recordName)
                                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            }),
                            .default(Text("Date"), action: {
                                self.showingView = false
                                var tempData = data
                                tempData.value = .date(val: TreeDateType(date: Date(), type: UIDatePicker.Mode.date.rawValue))
                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                            }),
                            .default(Text("On/Off"), action: {
                                var tempData = data
                                tempData.value = .toggle(val: false)
                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                            }),
                            .default(Text("Image"), action: {
                                self.showingView = false
                                var tempData = data
                                tempData.value = .image(recordName: "")
                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                            }),
                            .default(Text("Link"), action: {
                                self.showingView = false
                                var tempData = data
                                tempData.value = .link(val: "")
                                TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                            }),
                            .cancel()
                        ])
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
                                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                            })
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
                        ViewModel().showDetailView(title: data.title, recordName: recordName) { (longText) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                CloudManager.shared.updateData(recordName: recordName,
                                                               key: "text",
                                                               value: longText as CKRecordValue) { (result) in
                                                                switch result {
                                                                case .success:
                                                                    break
                                                                case .failure(let error):
                                                                    print(error.localizedDescription)
                                                                }
                                }
                            }
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
                        var tempData = data
                        tempData.value = .int(val: val + 1)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                    }, onDecrement: {
                        var tempData = data
                        tempData.value = .int(val: val - 1)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
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
                                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
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
                        ViewModel().getDateString(treeDate: val)
                            .padding()
                    }).actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Type Select"), message: Text("Please select date type."), buttons: [
                            .default(Text("D-Day"), action: {
                                let pickerView = OQPickerView.sharedInstance
                                pickerView.showDate(title: "Select Date", datePickerMode: UIDatePicker.Mode.date) { (date) in
                                    UIApplication.shared.windows[0]
                                        .rootViewController?
                                        .showAlert(title: "D-Day Type",
                                                   message: "Would you like to include the first day?",
                                                   doneCompletion: {
                                                    var tempData = data
                                                    tempData.value = .date(val: TreeDateType(date: date, type: DateTypeDDayIncludeFirstDay))
                                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                        }, cancelCompletion: {
                                            var tempData = data
                                            tempData.value = .date(val: TreeDateType(date: date, type: DateTypeDDay))
                                            TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                        })
                                }
                                pickerView.overrideUserInterfaceStyle = .light
                                
                                UIApplication.shared.windows[0].rootViewController?.view.addSubview(pickerView)
                            }),
                            .default(Text("Date And Time"), action: {
                                let pickerView = OQPickerView.sharedInstance
                                pickerView.showDate(title: "Select Date", datePickerMode: UIDatePicker.Mode.dateAndTime) { (date) in
                                    var tempData = data
                                    tempData.value = .date(val: TreeDateType(date: date, type: UIDatePicker.Mode.dateAndTime.rawValue))
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                }
                                pickerView.overrideUserInterfaceStyle = .light
                                
                                UIApplication.shared.windows[0].rootViewController?.view.addSubview(pickerView)
                            }),
                            .default(Text("Date"), action: {
                                let pickerView = OQPickerView.sharedInstance
                                pickerView.showDate(title: "Select Date", datePickerMode: UIDatePicker.Mode.date) { (date) in
                                    var tempData = data
                                    tempData.value = .date(val: TreeDateType(date: date, type: UIDatePicker.Mode.date.rawValue))
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                }
                                pickerView.overrideUserInterfaceStyle = .light
                                
                                UIApplication.shared.windows[0].rootViewController?.view.addSubview(pickerView)
                            }),
                            .default(Text("Time"), action: {
                                let pickerView = OQPickerView.sharedInstance
                                pickerView.showDate(title: "Select Date", datePickerMode: UIDatePicker.Mode.time) { (date) in
                                    var tempData = data
                                    tempData.value = .date(val: TreeDateType(date: date, type: UIDatePicker.Mode.time.rawValue))
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
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
                        if let image = ViewModel().getImageOrNil(name: recordName) {
                            ViewModel().showImageCropView(image: image) { (image) in
                                guard let newImage = image else {
                                    var tempData = data
                                    tempData.value = .image(recordName: "")
                                    TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                    return
                                }
                                
                                guard let imgData = newImage.pngData() else {
                                    return
                                }
                                
                                ViewModel().removeImage(name: recordName)   //이미지 삭제
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    ViewModel().saveImage(data: data, imgData: imgData)
                                }
                            }
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
                        ViewModel().getImage(name: recordName)
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
                        ImagePicker(pickerType: self.pickerType) { (imgData) in
                            ViewModel().saveImage(data: data, imgData: imgData)
                        }
                    }
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
                    }).actionSheet(isPresented: self.$showingView) {
                        ActionSheet(title: Text("Menu"), message: Text("Please select menu.\n[\(val)]"), buttons: [
                            .default(Text("Edit website"), action: {
                                UIApplication.shared.windows[0]
                                    .rootViewController?
                                    .showTextFieldAlert(title: "Input Value",
                                                        text: "",
                                                        placeHolder: "www.google.com",
                                                        doneCompletion: { (text) in
                                                            let url = text.makeUrlValidation()
                                                            var tempData = data
                                                            tempData.value = .link(val: url)
                                                            TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                    })
                            }),
                            .default(Text("Edit phone number"), action: {
                                UIApplication.shared.windows[0]
                                    .rootViewController?
                                    .showTextFieldAlert(title: "Input Value",
                                                        text: "",
                                                        placeHolder: "tel number...",
                                                        isNumberOnly: true,
                                                        doneCompletion: { (text) in
                                                            var tempData = data
                                                            tempData.value = .link(val: "tel:\(text)")
                                                            TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                                    })
                            }),
                            .default(Text("Open"), action: {
                                if !ViewModel().openLink(val) {
                                    print("url is unavailable: \(val)")
                                    UIApplication.shared.windows[0]
                                        .rootViewController?.showConfirmAlert(title: "Info", message: "link is unavailable. [\(val)]")
                                }
                            }),
                            .cancel()
                        ])
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
            TreeNode(treeData: TreeModel(title: "longText", value: .longText(recordName: "2123"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "toggle", value: .toggle(val: true), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "image", value: .image(recordName: "12313"), key:RootKey, index: 0))
            TreeNode(treeData: TreeModel(title: "link", value: .link(val: "www.naver.com"), key:RootKey, index: 0))
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
