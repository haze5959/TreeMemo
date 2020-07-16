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
    let bodyViewInfo: BodyViewInfo
    
    @State var hideLoadingBar = true
    
    @ObservedObject var treeMemoState = TreeMemoState.shared
    @Environment(\.presentationMode) public var presentation
    
    init(title: String?, treeDataKey: UUID) {
        self.title = title
        self.treeDataKey = treeDataKey
        self.bodyViewInfo = BodyViewInfo(title: title)
    }
    
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
                            if self.bodyViewInfo.depth > 0 {
                                TreeMemoState.shared.popHierarchy()
                            } else {
                                self.environment.openSideMenu.toggle()
                            }
                        }
            }, including: self.environment.isEdit ? .subviews : .gesture)
            .onAppear { self.bodyViewInfo.apearTask() }
            .onReceive(self.bodyViewInfo.dismissSub, perform: { _ in
                if self.presentation.wrappedValue.isPresented {
                    self.presentation.wrappedValue.dismiss()
                } else {
                    self.bodyViewInfo.isNeedDismiss = true
                }
            })
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
        }
        .onAppear { self.bodyViewInfo.apearTask() }
        .onReceive(self.bodyViewInfo.dismissSub, perform: { _ in
            self.presentation.wrappedValue.dismiss()
        })
    }
    #endif
    
    func move(from source: IndexSet, to destination: Int) {
        self.hideLoadingBar = false
        DispatchQueue.main.async {
            self.treeMemoState.moveTreeData(key: self.treeDataKey, indexSet: source, to: destination)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hideLoadingBar = true
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.hideLoadingBar = false
        DispatchQueue.main.async {
            self.treeMemoState.removeTreeData(key: self.treeDataKey, indexSet: offsets)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hideLoadingBar = true
        }
    }
}

class BodyViewInfo {
    public var depth: Int = 0
    var title: String? = nil
    public var isNeedInit = true
    public var isNeedDismiss = false
    private var subscriptions = Set<AnyCancellable>()
    let dismissSub = PassthroughSubject<Void, Never>()
    
    init(title: String?) {
        if let title = title {
            self.title = title
            TreeMemoState.shared.$treeHierarchy
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (treeHierarchy) in
                    guard let self = self else {
                        return
                    }
                    
                    if treeHierarchy.count < self.depth {
                        self.dismissSub.send()
                    }
            }.store(in: &self.subscriptions)
        }
    }
    
    func apearTask() {
        let treeMemoState = TreeMemoState.shared
        
        if self.isNeedDismiss {
            self.dismissSub.send()
            self.isNeedDismiss = false
        } else if let title = title, self.depth == 0 || self.depth > treeMemoState.treeHierarchy.count {
            treeMemoState.treeHierarchy.append(title)
            self.depth = treeMemoState.treeHierarchy.count
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
