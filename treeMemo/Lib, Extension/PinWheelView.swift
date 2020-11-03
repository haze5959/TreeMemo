//
//  PinWheelView.swift
//  PinWheelView
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//

import UIKit
import SwiftUI

open class PinWheelView {
    var containerView = UIView()
    var progressView = UIView()
    var labelView = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    
    open class var shared: PinWheelView {
        struct Static {
            static let instance: PinWheelView = PinWheelView()
        }
        return Static.instance
    }
    
    open func showProgressView() {
        #if !TODAY_EXTENTION && !WIDGET_EXTENTION
        guard let rootVC = UIApplication.shared.windows[0].rootViewController else {
            return
        }
        
        self.showProgressView(rootVC.view)
        #endif
    }
    
    open func showProgressView(_ view: UIView, text: String = "iCloud Sync...", completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.containerView.frame = view.frame
            self.containerView.center = view.center
            self.containerView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.3)
            
            self.progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            self.progressView.center = view.center
            self.progressView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
            self.progressView.clipsToBounds = true
            self.progressView.layer.cornerRadius = 10
            
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.activityIndicator.style = .large
            self.activityIndicator.center = CGPoint(x: self.progressView.bounds.width / 2, y: self.progressView.bounds.height / 2)
            
            self.labelView.text = text
            self.labelView.frame = CGRect(x: view.frame.size.width/2 - 100, y: self.progressView.frame.origin.y + 85, width: 200, height: 20)
            self.labelView.textAlignment = .center;
            
            self.progressView.addSubview(self.activityIndicator)
            self.containerView.addSubview(self.progressView)
            self.containerView.addSubview(self.labelView)
            view.addSubview(self.containerView)
            
            self.activityIndicator.startAnimating()
            
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    completion()
                }
            }
        }
    }
    
    open func hideProgressView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.containerView.removeFromSuperview()
        }
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
