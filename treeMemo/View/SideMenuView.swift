//
//  SideMenuView.swift
//  treeMemo
//
//  Created by OQ on 2020/01/26.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI

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
                    VStack {
                        CircleImageView(image: Image("TestImg"))
                            .frame(width: 200, height: 180, alignment: .center)
                        Text("Tree Memo")
                            .padding(.bottom, 20)
                    }
                    
                    Button(action: {
                        print("프리미엄 버전 구입")
                        let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
                        sceneDelegate.showPhurcaseDialog()
                    }) {
                        HStack {
                            Image(systemName: "rosette")
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

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(width: 240, isOpen: true)
    }
}
