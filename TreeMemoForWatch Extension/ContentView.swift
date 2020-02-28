//
//  ContentView.swift
//  TreeMemoForWatch Extension
//
//  Created by OGyu kwon on 2020/02/19.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var treeMemoState = TreeMemoState.shared
    
    var body: some View {
        ZStack {
            VStack {
                //바디
                BodyView(title: nil, treeDataKey: RootKey)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
