//
//  View+TreeMemo.swift
//  treeMemo
//
//  Created by OQ on 2019/12/08.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit
import Combine

extension UIViewController {
    func showTextFieldAlert(title: String, text: String? = nil, placeHolder: String, isNumberOnly: Bool = false, doneCompletion: @escaping (_ text: String) -> Void) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.text = text
            textField.placeholder = placeHolder
            if isNumberOnly {
                textField.keyboardType = .numberPad
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let doneBtn = UIAlertAction(title: "Done", style: .default, handler: { action in
            if let textField = alert.textFields?.first,
                let text = textField.text,
                text.count > 0 {
                doneCompletion(text)
            } else {
                doneCompletion("_")
            }
        })
        
        alert.addAction(doneBtn)
        
        self.present(alert, animated: true)
    }
    
    /**
     키보드 가리기 제스처 추가
     */
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /**
     키보드 가리기
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
