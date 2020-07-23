//
//  SideMenuView.swift
//  treeMemo
//
//  Created by OQ on 2020/01/26.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI
import StoreKit

#if os(iOS)
struct SideMenuView: View {
    @EnvironmentObject var environment: EnvironmentState
    @Environment(\.colorScheme) var colorScheme
    
    let width: CGFloat
    let isOpen: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .animation(Animation.easeIn(duration: 0.25))
            .onTapGesture {
                self.environment.openSideMenu.toggle()
            }
            
            HStack {
                List {
                    VStack {
                        CircleImageView(image: Image("Logo"))
                            .frame(width: 200, height: 180, alignment: .center)
                        Text("Tree Memo")
                            .padding(.bottom, 20)
                    }
                    
                    Button(action: {
                        let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
                        if PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
                            sceneDelegate.premiumConfirmAlert()
                        } else {
                            sceneDelegate.showPhurcaseDialog()
                        }
                    }) {
                        HStack {
                            if PremiumProducts.store.isProductPurchased(PremiumProducts.premiumVersion) {
                                Image(systemName: "rosette")
                            } else {
                                Image(systemName: "cart")
                            }
                            Text("Premium Version")
                        }.padding()
                    }
                    
                    Button(action: {
                        UIApplication.shared.windows[0]
                            .rootViewController?
                            .showAlert(title: "", message: "Are you sure you want to remove all data?", doneCompletion: {
                                TreeMemoState.shared.removeAllTreeData()
                            })
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove All Data")
                        }.padding()
                    }
                    
                    HStack {
                        Text("Dark Mode")
                        OQToggleView(model: ToggleModel(isOn: self.colorScheme == .dark, action: { (isOn) in
                            UserDefaults().set(isOn, forKey: "UDUseDarkMode")
                            
                            UIApplication.shared.windows[0]
                                .rootViewController?
                                .showConfirmAlert(title: "",
                                                  message: "The app is closed to reflect the dark mode.",
                                                  confirmText: "OK",
                                                  doneCompletion: {
                                                    CloudManager.shared.store.synchronize()
                                                    exit(0)
                                })
                        }))
                    }.padding()
                    
                    Button(action: {
                        let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
                        sceneDelegate.showDonationDialog()
                    }) {
                        HStack {
                            Image(systemName: "hand.thumbsup")
                            Text("Donation")
                        }.padding()
                    }
                    
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id1506875143")!, options: [:], completionHandler: nil)
                    }) {
                        HStack {
                            Image(systemName: "star")
                            Text("Review")
                        }.padding()
                    }
                }
                .frame(width: self.width)
                .background(Color.black)
                .offset(x: self.isOpen ? 0 : -self.width)
                .animation(.default)
                
                Spacer()
            }
        }
    }
}
#else
struct SideMenuView: View {
    @EnvironmentObject var environment: EnvironmentState
    
    let width: CGFloat
    let isOpen: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .animation(Animation.easeIn(duration: 0.25))
            .onTapGesture {
                self.environment.openSideMenu.toggle()
            }
            
            HStack {
                List {
                    Text("개발중")
                }
                .frame(width: self.width)
                .background(Color.black)
                .offset(x: self.isOpen ? 0 : -self.width)
                .animation(.default)
                
                Spacer()
            }
        }
    }
}
#endif


struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(width: 240, isOpen: true)
    }
}
