//
//  TreeMemoViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/28.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit
import SwiftUI

class ViewModel: ObservableObject {
    func getImage(path: String) -> Image {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imagePath = "\(documentsPath)/\(path)"
        if let image = UIImage(contentsOfFile: imagePath) {
            return Image(uiImage: image)
        } else {
            return Image(systemName: "photo")
        }
    }
    
    func getDateString(treeDate: TreeDateType) -> String {
        let date = treeDate.date
        let type = UIDatePicker.Mode.init(rawValue: treeDate.type)
        
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
    
    func dismissViewController() {
        let rootVC = UIApplication.shared.windows[0].rootViewController
        let presentedVC = rootVC?.presentedViewController
        presentedVC?.dismiss(animated: true)
    }
}
