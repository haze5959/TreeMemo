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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var reviewTimer: Timer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(EnvironmentState())

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            window.rootViewController?.hideKeyboardWhenTappedAround()
            self.window = window
            window.makeKeyAndVisible()
        }
        
        self.showReviewTimer(second: 180)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
            if !PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
                self.showPhurcaseDialog()
            }
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
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // MARK: - Review
    func showReviewTimer(second:Int) {
        DispatchQueue.main.async {
            if PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
                if !UserDefaults().bool(forKey: "sawReview") {
                    self.reviewTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(second), repeats: true, block: { timer in
                        self.reviewTimer?.invalidate()
                        self.reviewTimer = nil
                        SKStoreReviewController.requestReview()   //리뷰 평점 작성 메서드
                        UserDefaults().set(true, forKey: "sawReview")
                    })
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
        
        if let presentedVC = rootVC.presentedViewController {
            rootVC = presentedVC
        }
        
        if IAPHelper.canMakePayments() {
            let loadingDialog = Dialog.loading(title: "Please wait...", message: "", image: nil)
            loadingDialog.show(in: rootVC)
            
            PremiumProducts.store.requestProducts { (success, products) in
                loadingDialog.dismiss(animated: true, completion: {
                    if success, let product = products?.first {
                        DispatchQueue.main.async {
                            let d = Dialog.alert(title: product.localizedTitle, message: product.localizedDescription, image: #imageLiteral(resourceName: "TestImg"))
                            
                            let numberFormatter = NumberFormatter()
                            let locale = product.priceLocale
                            numberFormatter.numberStyle = .currency
                            numberFormatter.locale = locale
                            d.addAction(title: numberFormatter.string(from: product.price)!, handler: { (dialog) -> (Void) in
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
                            
                            d.addAction(title: "Purchase Restore", handler: { (dialog) -> (Void) in
                                PremiumProducts.store.restorePurchases()
                                dialog.dismiss()
                                self.reviewTimer?.invalidate()
                                self.reviewTimer = nil
                                self.showReviewTimer(second: 180)
                            })
                            
                            DispatchQueue.main.async {
                                d.show(in: rootVC)
                            }
                        }
                    } else {
                        print("showPhurcaseDialog 실패!!!")
                    }
                })
            }
        } else {
            let d = Dialog.alert(title: "Info", message: "Payment unavailable.")
            d.addAction(title: "Done", handler: { (dialog) -> (Void) in
                dialog.dismiss()
            })
            d.show(in: rootVC)
        }
    }
    
    func showDonationDialog() {
    }
    
    @objc func buyComplete() {
        PinWheelView.shared.hideProgressView()
        
        guard let rootVC = self.window?.rootViewController else {
            print("Not found rootVC!")
            return
        }
        let d = Dialog.alert(title: "Info", message: "Purchase completed!", image: #imageLiteral(resourceName: "TestImg"))
        d.addAction(title: "Confirm", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        })
        d.show(in: rootVC)
    }
    
    @objc func buyFail() {
        PinWheelView.shared.hideProgressView()
    }
}

