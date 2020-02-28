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
    let wcSession = TreeMemoWCSession()
    
    @Published var treeHierarchy = [String]()
    
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
    
    let storedDataKey = "storedDataKey"
    let treeStore = UserDefaults(suiteName: "group.oq.treememo")!
    
    init() {
        self.cancellable = self.$treeData
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map({ (treeData) -> TreeDataType? in
                if self.notSaveOnce {
                    self.notSaveOnce = false
                    return nil
                }
                
                print("데이터 저장!")
                self.saveTreeData(treeData)
                return treeData
            })
            .debounce(for: 2, scheduler: RunLoop.main)
            .sink(receiveValue: { (treeData) in
                guard let treeData = treeData else {
                    return
                }
                
                print("클라우드 동기화!!")
                // Watch <-> Phone Data sharing
                self.wcSession.sendTreeData(treeData: treeData)
            })
    }
    
    // MARK: 트리데이터 초기화
    func initTreeData() {
        self.updateTreeDataWithNotSave(treeData: self.loadTreeData())
    }
    
    func saveTreeData(_ value: TreeDataType) {
        guard let encodedTreeData = try? PropertyListEncoder().encode(value) else {
            print("save encoding fail!")
            return
        }
        
        treeStore.set(encodedTreeData, forKey: self.storedDataKey)
    }
    
    func loadTreeData() -> TreeDataType {
        if let data = treeStore.value(forKey: self.storedDataKey) as? Data,
            let treeData = try? PropertyListDecoder().decode(TreeDataType.self, from: data) {
            
            return treeData
        } else {
            //페이지 첫 진입
            var treeData = TreeDataType()
            let rootData = [TreeModel]()
            
            treeData.updateValue(rootData, forKey: RootKey)
            self.treeData = treeData
            return treeData
        }
    }
    
    func removeAllTreeData() {
        treeStore.removeObject(forKey: self.storedDataKey)
        self.initTreeData()
    }
    
    func updateTreeDataWithNotSave(treeData: TreeDataType) {
        self.notSaveOnce = true
        self.treeData = treeData
    }
    
    /**
     해당 Key의 트리데이터 리턴
     */
    func getTreeData(key: UUID, isEditMode: Bool = false) -> [TreeModel] {
        guard var subTreeData = self.treeData[key] else {
            print("Can't find data with key!")
            let subTreeData = [TreeModel]()
            self.treeData.updateValue(subTreeData, forKey: key)
            return subTreeData
        }
        
        if !isEditMode || subTreeData.count == 0 {
            subTreeData.append(self.getPlusTreeModel(key: key, index: subTreeData.count))
        }
        
        return subTreeData
    }
    
    func removeTreeData(key: UUID, indexSet: IndexSet) {
        guard var subTreeData = self.treeData[key] else {
            print("Can't find data with key!")
            return
        }
        
        // 삭제될 데이터
        if let index = indexSet.map({$0}).first {
            let treeData = subTreeData[index]
            self.removeRecursiveData(treeData: treeData)
        }
        
        subTreeData.remove(atOffsets: indexSet)
        self.treeData[key] = subTreeData
    }
    
    func moveTreeData(key: UUID, indexSet: IndexSet, to destination: Int) {
        guard var subTreeData = self.treeData[key] else {
            print("Can't find data with key!")
            return
        }
        
        subTreeData.move(fromOffsets: indexSet, toOffset: destination)
        
        var movedTreeData = [TreeModel]()
        for (index, treeData) in subTreeData.enumerated() {
            var tempTreeData = treeData
            tempTreeData.index = index
            movedTreeData.append(tempTreeData)
        }

        self.treeData[key] = movedTreeData
    }
    
    func selectTreeHierarchy(index: Int) {
        let removeCount = self.treeHierarchy.count - (index + 1)
        self.treeHierarchy.removeLast(removeCount)
    }
    
    func popHierarchy() {
        self.treeHierarchy.removeLast(1)
    }
    
    func getPlusTreeModel(key: UUID, index: Int) -> TreeModel {
        return TreeModel(title: "New", value: .new, key: key, index: index)
    }
    
    func removeRecursiveData(treeData: TreeModel) {
        switch treeData.value {
        case .child(let key):
            guard let subTreeDatas = self.treeData[key] else {
                print("Can't find data with key!")
                return
            }
            
            for subTreeData in subTreeDatas {
                self.removeRecursiveData(treeData: subTreeData)
            }
            
            self.treeData.removeValue(forKey: key)
        default:
            break
        }
    }
}
