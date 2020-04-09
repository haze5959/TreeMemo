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
                    .alert(isPresented: self.$alertState.showAlert) {
                        switch self.alertState.activeAlert {
                        case .notSupport:
                            return Alert(title: Text(self.alertState.notSupportText))
                        case .notPared:
                            return Alert(title: Text(self.alertState.notParedText), dismissButton: .cancel(Text("Refresh"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    TreeMemoState.shared.wcSession.requestTreeData()
                                }
                            }))
                        }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
