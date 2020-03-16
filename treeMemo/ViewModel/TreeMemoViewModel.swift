//
//  TreeMemoViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/28.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit
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
                        tempData.value = .image(imagePath: recordName)
                        TreeMemoState.shared.treeData[data.key]![data.index] = tempData
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func removeImage(name: String) {
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let path = "\(documentsPath)/\(name).png"
            try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            
            CloudManager.shared.deleteData(recordType: "Image", recordName: name)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDateString(treeDate: TreeDateType) -> String {
        let date = treeDate.date
        let type = UIDatePicker.Mode(rawValue: treeDate.type)
        
        let dateFormatter = DateFormatter()
        if type == .dateAndTime {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
        } else if type == .date {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .long
        } else {    //time
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        
        return dateFormatter.string(from: date)
    }
    
    func showDetailView(title: String, text: String, completion: @escaping (String)->Void) {
        let rootVC = UIApplication.shared.windows[0].rootViewController
        let textDetailVC = UIHostingController(rootView: TextDetailView(title: title, text: text, completeHandler: completion))
        
        rootVC?.present(textDetailVC, animated: true)
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
}
