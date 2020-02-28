//
//  BodyView.swift
//  TreeMemoForWatch Extension
//
//  Created by OGyu kwon on 2020/02/19.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

struct BodyView: View {
    let title: String?
    let treeDataKey: UUID
    
    //뷰디드로드 같은 초기화 구문이 없어서 이런거 추가함... 스위프트ui 존망이다 진짜
    @State private var depth: Int = 0
    @State private var isNeedInit = true
    @State private var isNeedDismiss = false
    @State private var subscriptions = Set<AnyCancellable>()
    
    @ObservedObject var treeMemoState = TreeMemoState.shared
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        List {
            ForEach(self.treeMemoState.getTreeData(key: self.treeDataKey)) { treeData in
                TreeNode(treeData: treeData)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationBarTitle(self.title ?? "Tree Memo")
        .onAppear {
            if self.isNeedInit, let title = self.title {
                self.isNeedInit = false
                self.treeMemoState.treeHierarchy.append(title)
                self.depth = self.treeMemoState.treeHierarchy.count
                
                self.treeMemoState.$treeHierarchy
                    .receive(on: DispatchQueue.main)
                    .sink { (treeHierarchy) in
                        if treeHierarchy.count < self.depth {
                            self.isNeedDismiss = true
                            self.presentation.wrappedValue.dismiss()
                        }
                }.store(in: &self.subscriptions)
            }
            
            if self.isNeedDismiss {
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BodyView(title: "TEST", treeDataKey: RootKey)
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
