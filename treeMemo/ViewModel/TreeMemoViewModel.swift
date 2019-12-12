//
//  TreeMemoViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/28.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit

class ViewModel: ObservableObject {
    func getImage(path: String) -> UIImage {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imagePath = "\(documentsPath)/\(path)"
        if let image = UIImage(contentsOfFile: imagePath) {
            return image
        } else {
            return UIImage(systemName: "photo")!
        }
    }
}
