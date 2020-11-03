//
//  View+TreeMemo.swift
//  treeMemo
//
//  Created by OQ on 2019/12/08.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit
import SwiftUI
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
        
        if let presentedVC = self.presentedViewController {
            presentedVC.present(alert, animated: true)
        } else {
            self.present(alert, animated: true)
        }
    }
    
    func showAlert(title: String, message: String, doneCompletion: @escaping () -> Void, cancelCompletion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: { action in
            cancelCompletion?()
        }))
        
        let doneBtn = UIAlertAction(title: "OK", style: .default, handler: { action in
            doneCompletion()
        })
        alert.addAction(doneBtn)
        
        if let presentedVC = self.presentedViewController {
            presentedVC.present(alert, animated: true)
        } else {
            self.present(alert, animated: true)
        }
    }
    
    func showConfirmAlert(title: String, message: String, confirmText: String = "Cancel", doneCompletion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmText, style: .cancel, handler: { action in
            doneCompletion?()
        }))
        
        if let presentedVC = self.presentedViewController {
            presentedVC.present(alert, animated: true)
        } else {
            self.present(alert, animated: true)
        }
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
    
    /**
     addSubview
     */
    func addPopup(_ child: UIViewController, frame: CGRect? = nil) {
        self.addChild(child)
        
        if let frame = frame {
            child.view.frame = frame
        } else {
            child.view.frame = self.view.frame
        }
        
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /**
     removeFromSuperview
     */
    func removePopup() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

extension UIWindow {
    /// UIApplication.shared.windows.first 리턴
    static var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
