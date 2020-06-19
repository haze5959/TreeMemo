//
//  TreeMemoViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/28.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

#if os(iOS)
import UIKit
#endif
import SwiftUI
import CloudKit

class ViewModel: ObservableObject {
    func getImageOrNil(name: String) -> UIImage? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imagePath = "\(documentsPath)/\(name).png"
        if let image = UIImage(contentsOfFile: imagePath) {
            return image
        } else {
            return nil
        }
    }
    
    func getImage(name: String) -> some View {
        if name.count == 0 {
            return AnyView(Image(systemName: "photo")
                .padding())
        } else {
            if let image = self.getImageOrNil(name: name) {
                return AnyView(Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(.trailing))
            } else {
                return AnyView(Image(systemName: "icloud.and.arrow.down")
                    .padding())
            }
        }
    }
    
    func saveImage(data: TreeModel, imgData: Data) {
        #if !TODAY_EXTENTION
        let record = CKRecord(recordType: "Image")
        record.setValue(imgData, forKey: "data")
        CloudManager.shared.makeData(record: record) { (result) in
            switch result {
            case .success(let record):
                let recordName = record.recordID.recordName
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let newPath = "\(documentsPath)/\(recordName).png"
                DispatchQueue.main.async {
                    do {
                        try imgData.write(to: URL(fileURLWithPath: newPath))
                        var tempData = data
                        tempData.value = .image(recordName: recordName)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        #endif
    }
    
    func removeImage(name: String) {
        #if !TODAY_EXTENTION
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let path = "\(documentsPath)/\(name).png"
            try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            
            CloudManager.shared.deleteData(recordType: "Image", recordName: name)
        } catch {
            print(error.localizedDescription)
        }
        #endif
    }
    
    func getDateString(treeDate: TreeDateType) -> String {
        let date = treeDate.date
        let type = UIDatePicker.Mode(rawValue: treeDate.type)
        
        let dateFormatter = DateFormatter()
        if type == .dateAndTime {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
        } else if type == .date {
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .long
        } else if type?.rawValue == DateTypeDDay {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return "(\(dateFormatter.string(from: date))) D-Day: \(date.relativeDaysFromToday())"
        } else if type?.rawValue == DateTypeDDayIncludeFirstDay {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return "(\(dateFormatter.string(from: date))) D-Day: \(date.relativeDaysFromToday(includeFirstDay: true))"
        } else {    //time
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        
        return dateFormatter.string(from: date)
    }
    
    #if !TODAY_EXTENTION
    func showDetailView(title: String, recordName: String, completion: @escaping (String)->Void) {
        if let longText = UserDefaults().string(forKey: "LT_\(recordName)") {
            let rootVC = UIApplication.shared.windows[0].rootViewController
            let textDetailVC = UIHostingController(rootView: TextDetailView(title: title, text: longText, completeHandler: completion))
            textDetailVC.modalPresentationStyle = .fullScreen
            rootVC?.present(textDetailVC, animated: true)
        } else {    // 클라우드에서 값을 가져온다.
            CloudManager.shared.getData(recordType: "Text",
                                        recordName: recordName) { (result) in
                                            switch result {
                                            case .success(let records):
                                                guard records.count > 0, let longText = records[0].value(forKey: "text") as? String else {
                                                    print("No longText data!")
                                                    return
                                                }
                                                
                                                UserDefaults().set(longText, forKey: "LT_\(recordName)")
                                                DispatchQueue.main.async {
                                                    let rootVC = UIApplication.shared.windows[0].rootViewController
                                                    let textDetailVC = UIHostingController(rootView: TextDetailView(title: title, text: longText, completeHandler: completion))
                                                    textDetailVC.modalPresentationStyle = .fullScreen
                                                    rootVC?.present(textDetailVC, animated: true)
                                                }
                                            case .failure(let error):
                                                print(error.localizedDescription)
                                            }
            }
        }
    }
    
    func showImageCropView(image: UIImage, saveClosure: @escaping (UIImage?) -> Void) {
        if let rootVC = UIApplication.shared.windows[0].rootViewController {
            let imageVC = OQImageViewController()
            imageVC.image = image
            imageVC.saveClosure = saveClosure
            imageVC.view.frame = rootVC.view.frame
            imageVC.modalPresentationStyle = .fullScreen
            rootVC.present(imageVC, animated: true)
        }
    }
    
    func dismissViewController() {
        let rootVC = UIApplication.shared.windows[0].rootViewController
        let presentedVC = rootVC?.presentedViewController
        presentedVC?.dismiss(animated: true)
    }
    
    func openLink(_ url: String) -> Bool {
        var aUrl: String
        
        if !url.isEmpty {
            aUrl = url
        } else {
            return false
        }
        
        if !url.isRegex("://") && !url.isRegex("tel:") {
            if url.isPhoneNumber() {
                aUrl = "telprompt://" + url
            } else {
                aUrl = "http://" + url
            }
        }
        
        if let bUrl: URL = URL(string: aUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(bUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(bUrl)
            }
            return true
        } else {
            return false
        }
    }
    #endif
}
