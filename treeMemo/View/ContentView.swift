//
//  ContentView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/19.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
            
            VStack {
                //해더
                HeaderView()
                
                //바디
                NavigationView {
                    BodyView(title: nil, treeDataKey: RootKey)
                }
                //이거하면 셀 삭제하기 제스쳐가 잘 작동안함
//                .gesture(
//                    DragGesture()
//                        .onEnded({gesture in
//                            if gesture.startLocation.x < CGFloat(60.0) {
//                                print("edge pan")
//                                if TreeMemoState.shared.treeHierarchy.count > 0 {
//                                    TreeMemoState.shared.treeHierarchy.removeLast()
//                                }
//                            }
//                            }
//                    )
//                )
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([
            "iPhone SE",
            //            "iPhone XS Max"
        ], id: \.self) { deviceName in
            Group {
                ContentView()
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                
                ContentView()
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}
