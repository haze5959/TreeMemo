//
//  ContentView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/19.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var environment: EnvironmentState
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
            
            VStack {
                //해더
                HeaderView()
                
                //바디
                NavigationView {
                    BodyView(title: nil, treeDataKey: RootKey)
                }.navigationViewStyle(StackNavigationViewStyle())
            }
            
            SideMenuView(width: 240,
                         isOpen: self.environment.openSideMenu)
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
