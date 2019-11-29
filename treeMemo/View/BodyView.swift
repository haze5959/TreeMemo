//
//  BodyView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

struct BodyView: View {
    let title: String?
    let treeDataKey: Double
    let depth: Int
    let viewModel = TreeMemoViewModel()
    
    //뷰디드로드 같은 초기화 구문이 없어서 이런거 추가함... 스위프트ui 존망이다 진짜
    @State private var isNeedInit = true
    @State private var isNeedDismiss = false
    @State private var cancellable: AnyCancellable?
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        List(self.viewModel.getTreeData(key: treeDataKey)) { treeData in
            TreeNode(treeData: treeData)
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .onAppear {
            if self.isNeedInit, let title = self.title {
                self.isNeedInit = false
                TreeMemoState.shared.treeHierarchy.append(title)
                
                self.cancellable = TreeMemoState.shared.$treeHierarchy
                    .receive(on: DispatchQueue.main)
                    .sink { (treeHierarchy) in
                        if treeHierarchy.count < self.depth {
                            self.isNeedDismiss = true
                            self.presentation.wrappedValue.dismiss()
                        }
                }
            }
            
            if self.isNeedDismiss {
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: Preview
struct Body_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            BodyView(title: "TEST", treeDataKey: RootKey, depth: 0)
                .environment(\.colorScheme, .dark)
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
