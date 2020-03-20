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
    @ObservedObject var alertState = WatchAlertState.shared
    
    var body: some View {
        ZStack {
            VStack {
                //바디
                BodyView(title: nil, treeDataKey: RootKey)
                    .alert(isPresented: self.$alertState.notSupport) {
                        Alert(title: Text(self.alertState.notSupportText))}
                    .alert(isPresented: self.$alertState.notPared) {
                        Alert(title: Text(self.alertState.notParedText))}
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
