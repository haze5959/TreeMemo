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
                        CircleImageView(image: Image(systemName: "folder"))
                        Text("Tree Memo")
                    }
                    
                    Button(action: {
                        print("11111")
                    }) {
                        Text("11111")
                    }
                    
                    Button(action: {
                        print("2222")
                    }) {
                        Text("22222")
                    }
                }
//                .shadow(radius: 10)   //이거 주석풀면 세이프 에어리아 무시한다 쓰벌..
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
        SideMenuView(width: 200, isOpen: true)
    }
}
