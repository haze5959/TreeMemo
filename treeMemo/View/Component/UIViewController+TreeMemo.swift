//
//  View+TreeMemo.swift
//  treeMemo
//
//  Created by OQ on 2019/12/08.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit

extension UIViewController {
    func showTextFieldAlert(title: String, placeHolder: String, doneCompletion: @escaping (_ text: String) -> Void) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = placeHolder
        })
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
            alert.dismiss(animated: true) {
                let text = alert.textFields?.first?.text
                doneCompletion(text ?? "")
            }
        }))
        
        self.present(alert, animated: true)
    }
}
