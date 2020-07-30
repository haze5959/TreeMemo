//
//  SceneDelegate.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/19.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit
import SwiftUI
import StoreKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var reviewTimer: Timer?
    var currentPresentedVC: UIHostingController<SimpleBodyView>? = nil
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(EnvironmentState())
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            if let useDarkMode = UserDefaults().object(forKey: "UDUseDarkMode") as? Bool {
                window.overrideUserInterfaceStyle = useDarkMode ? .dark : .light
            }
            
            window.rootViewController = UIHostingController(rootView: contentView)
            window.rootViewController?.hideKeyboardWhenTappedAround()
            self.window = window
            window.makeKeyAndVisible()
        }
        
        self.showReviewTimer(second: 120)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
            if !PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
                self.showPhurcaseDialog()
            }
        }
        
        if let url = connectionOptions.urlContexts.first?.url {
            self.openViewByUrl(url: url)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        self.dismissDialog()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        self.openViewByUrl(url: url)
    }
    
    func dismissDialog() {
        guard var rootVC = self.window?.rootViewController else {
            print("Not found rootVC!")
            return
        }
        
        if let topVC = rootVC.presentedViewController {
            rootVC = topVC
        }
        
        if rootVC is Dialog {
            rootVC.dismiss(animated: true) {
                self.dismissDialog()
            }
        }
    }
    
    func openViewByUrl(url: URL) {
        let urlStr = url.absoluteString
        let folderKey = urlStr[11..<urlStr.count]
        if let uuid = UUID(uuidString: folderKey) {
            let closure = {
                let contentView = SimpleBodyView(title: "", treeDataKey: uuid)
                self.currentPresentedVC = UIHostingController(rootView: contentView)
                self.window?.rootViewController?.present(self.currentPresentedVC!, animated: true, completion: nil)
            }
            
            if let currentVC = self.currentPresentedVC {
                currentVC.dismiss(animated: false) {
                    closure()
                }
            } else {
                closure()
            }
        }
    }
    
    // MARK: - Review
    func showReviewTimer(second:Int) {
        DispatchQueue.main.async {
            if PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
                if !UserDefaults().bool(forKey: "sawReview") {
                    SKStoreReviewController.requestReview()   //리뷰 평점 작성 메서드
                    UserDefaults().set(true, forKey: "sawReview")
                }
            } else {
                self.reviewTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(second), repeats: true, block: { timer in
                    if !PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
                        self.showPhurcaseDialog()
                    }
                })
            }
        }
    }
        
    func showPhurcaseDialog() {
        guard var rootVC = self.window?.rootViewController else {
            print("Not found rootVC!")
            return
        }
        
        if let topVC = rootVC.presentedViewController {
            rootVC = topVC
        }
        
        guard (rootVC is Dialog) == false else {
            print("Dialog is exist...")
            rootVC.dismiss(animated: true, completion: nil)
            return
        }
        
        if IAPHelper.canMakePayments() {
            let dialog = Dialog.loading(title: "Please wait...", message: "", image: nil)
            dialog.show(in: rootVC)
            
            PremiumProducts.store.requestProducts { (success, products) in
                dialog.dismiss(animated: true, completion: {
                    if success {
                        guard let product = products?.filter({
                            $0.productIdentifier == PremiumProducts.premiumVersion
                        }) .first else {
                            print("Not found premiumVersion")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            let dialog = Dialog.alert(title: product.localizedTitle, message: product.localizedDescription, image: #imageLiteral(resourceName: "Logo"))
                            
                            let numberFormatter = NumberFormatter()
                            let locale = product.priceLocale
                            numberFormatter.numberStyle = .currency
                            numberFormatter.locale = locale
                            dialog.addAction(title: numberFormatter.string(from: product.price)!, handler: { (dialog) -> (Void) in
                                PremiumProducts.store.buyProduct(product)
                                dialog.dismiss()
                                NotificationCenter.default.addObserver(self, selector: #selector(self.buyComplete),
                                                                       name: .IAPHelperPurchaseNotification,
                                                                       object: nil)
                                NotificationCenter.default.addObserver(self, selector: #selector(self.buyFail),
                                                                       name: .IAPHelperPurchaseFailNotification,
                                                                       object: nil)
                                PinWheelView.shared.showProgressView(rootVC.view, text: "Please wait...")
                            })
                            
                            dialog.addAction(title: "Purchase Restore", handler: { (dialog) -> (Void) in
                                PremiumProducts.store.restorePurchases()
                                dialog.dismiss()
                                NotificationCenter.default.addObserver(self, selector: #selector(self.buyComplete),
                                                                       name: .IAPHelperPurchaseNotification,
                                                                       object: nil)
                                NotificationCenter.default.addObserver(self, selector: #selector(self.buyFail),
                                                                       name: .IAPHelperPurchaseFailNotification,
                                                                       object: nil)
                                PinWheelView.shared.showProgressView(rootVC.view, text: "Please wait...")
                            })
                            
                            DispatchQueue.main.async {
                                dialog.show(in: rootVC)
                            }
                        }
                    } else {
                        print("showPhurcaseDialog 실패!!!")
                    }
                })
            }
        } else {
            let dialog = Dialog.alert(title: "Info", message: "Payment unavailable.")
            dialog.addAction(title: "Done", handler: { (dialog) -> (Void) in
                dialog.dismiss()
            })
            dialog.show(in: rootVC)
        }
    }
    
    func premiumConfirmAlert() {
        guard let rootVC = self.window?.rootViewController else {
            print("Not found rootVC!")
            return
        }
        let dialog = Dialog.alert(title: "Premium", message: "All features are available.", image: #imageLiteral(resourceName: "Logo"))
        dialog.addAction(title: "Confirm", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        })
        dialog.show(in: rootVC)
    }
    
    @objc func buyComplete() {
        PinWheelView.shared.hideProgressView()
        
        guard let rootVC = self.window?.rootViewController else {
            print("Not found rootVC!")
            return
        }
        
        var message = "Purchase completed!"
        if !PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
            message = "Purchase fail.."
        }
        
        let dialog = Dialog.alert(title: "Info", message: message, image: #imageLiteral(resourceName: "Logo"))
        dialog.addAction(title: "Confirm", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        })
        dialog.show(in: rootVC)
    }
    
    @objc func buyFail() {
        PinWheelView.shared.hideProgressView()
        
        guard let rootVC = self.window?.rootViewController else {
            print("Not found rootVC!")
            return
        }
        let dialog = Dialog.alert(title: "Info", message: "Purchase fail..", image: #imageLiteral(resourceName: "Logo"))
        dialog.addAction(title: "Confirm", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        })
        dialog.show(in: rootVC)
    }
}

