//
//  TreeMemoEnvironment.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/26.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

typealias TreeDataType = [UUID: [TreeModel]]
class TreeMemoState: ObservableObject {
    static let shared = TreeMemoState()
    
    @Published var treeDataKey = RootKey
    @Published var previousTreeDataKey = [RootKey]
    
    private var cancellable: AnyCancellable?
    private var notSaveOnce = false
    
    /**
     - 데이터 업데이트 방식
     - treeData는 로컬에 저장된다.
     - treeData의 변화가 일어나면 isNeededUpdate 상태가 바뀐다.
     - isNeededUpdate 상태도 유저디폴트로 로컬에 매번 저장된다.
     - isNeededUpdate가 true이면 클라우드 동기화 쓰로틀링이 일어난다.
     - 동기화가 되었다면 isNeededUpdate는 다시 false가 된다.
     */
    @Published var treeData = TreeDataType()
    
    init() {}
    
    // MARK: 트리데이터 초기화
    func initTreeData() {
        if let data = UserDefaults(suiteName: "group.oq.treememo")?.data(forKey: "RootTreeData"),
            let treeData = try? PropertyListDecoder().decode(TreeDataType.self, from: data) {
            self.treeData = treeData
        } else {
            //페이지 첫 진입
            var treeData = TreeDataType()
            let rootData = [TreeModel]()
            
            treeData.updateValue(rootData, forKey: RootKey)
            self.treeData = treeData
        }
    }
    
    /**
     해당 Key의 트리데이터 리턴
     */
    func getTreeData(isEditMode: Bool = false) -> [TreeModel] {
        guard var subTreeData = self.treeData[self.treeDataKey] else {
            print("Can't find data with key!")
            let subTreeData = [TreeModel]()
            self.treeData.updateValue(subTreeData, forKey: self.treeDataKey)
            return subTreeData
        }
        
        if self.treeDataKey != RootKey {    // 루트가 아니라면
            let model = TreeModel(title: "Back", value: .back, key: self.treeDataKey, index: 0)
            subTreeData.insert(model, at: 0)
        }
        
        if subTreeData.count > 7 {
            subTreeData.removeSubrange(7...)
            let model = TreeModel(title: "", value: .new, key: self.treeDataKey, index: 7)
            subTreeData.append(model)
        }
        
        return subTreeData
    }
    
    func getData(treeData: TreeDataType) -> Data {
        guard let jsonData = try? JSONEncoder().encode(treeData) else {
            print("treeData could not encoding!")
            return Data()
        }
        
        return jsonData
    }
    
    func historyBack() {
        if let treeDataKey = self.previousTreeDataKey.popLast() {
            self.treeDataKey = treeDataKey
        } else {
            self.treeDataKey = RootKey
        }
    }
}
