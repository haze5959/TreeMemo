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
    @EnvironmentObject var environment: EnvironmentState
    
    let title: String?
    let treeDataKey: UUID
    
    @State private var depth: Int = 0
    @State private var isNeedInit = true
    @State private var isNeedDismiss = false
    @State private var subscriptions = Set<AnyCancellable>()
    @State var hideLoadingBar = true
    
    @ObservedObject var treeMemoState = TreeMemoState.shared
    @Environment(\.presentationMode) var presentation
    
    #if os(iOS)
    @ViewBuilder
    var body: some View {
        if self.hideLoadingBar {
            List {
                ForEach(self.treeMemoState.getTreeData(key: self.treeDataKey, isEditMode: self.environment.isEdit)) { treeData in
                    TreeNode(treeData: treeData)
                        .buttonStyle(PlainButtonStyle())
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
                .environment(\.editMode, .constant(self.environment.isEdit ? EditMode.active : EditMode.inactive))
            }
            .environment(\.editMode, .constant(self.environment.isEdit ? EditMode.active : EditMode.inactive))
            .navigationBarHidden(true)
            .navigationBarTitle("")
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            if self.depth > 0 {
                                TreeMemoState.shared.popHierarchy()
                            } else {
                                self.environment.openSideMenu.toggle()
                            }
                        }
            }, including: self.environment.isEdit ? .subviews : .gesture)
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
        } else {
            LoadingView()
                .padding(.top, -200)
        }
    }
    #else
    var body: some View {
        List {
            ForEach(self.treeMemoState.getTreeData(key: self.treeDataKey, isEditMode: self.environment.isEdit)) { treeData in
                TreeNode(treeData: treeData)
                    .buttonStyle(PlainButtonStyle())
            }
            .onMove(perform: move)
            .onDelete(perform: delete)
        }.onAppear {
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
    #endif
    
    func move(from source: IndexSet, to destination: Int) {
        self.treeMemoState.moveTreeData(key: self.treeDataKey, indexSet: source, to: destination)
        self.hideLoadingBar = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hideLoadingBar = true
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.treeMemoState.removeTreeData(key: self.treeDataKey, indexSet: offsets)
        self.hideLoadingBar = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hideLoadingBar = true
        }
    }
}

// MARK: Preview
struct Body_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            BodyView(title: "TEST", treeDataKey: RootKey)
                .environment(\.colorScheme, .dark)
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
