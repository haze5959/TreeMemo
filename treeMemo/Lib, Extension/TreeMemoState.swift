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
    
    @Published var treeHierarchy = [String]()
    @State var isEdit = false
    
    private var cancellable: AnyCancellable?
    
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
    
    init() {
        self.cancellable = self.$treeData
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map({ (treeData) -> TreeDataType in
                print("데이터 저장!")
                self.saveTreeData(treeData)
                return treeData
            })
            .debounce(for: 2, scheduler: RunLoop.main)
            .sink(receiveValue: { (treeData) in
                print("클라우드 동기화!!")
                self.saveTreeData(treeData)
            })
    }
    
    func saveTreeData(_ value: TreeDataType) {
        guard let encodedTreeData = try? PropertyListEncoder().encode(value) else {
            print("save encoding fail!")
            return
        }
        
        UserDefaults().set(encodedTreeData, forKey: self.storedDataKey)
    }
    
    func loadTreeData() -> TreeDataType {
        if let data = UserDefaults.standard.value(forKey: self.storedDataKey) as? Data,
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
        UserDefaults.standard.removeObject(forKey: self.storedDataKey)
    }
    
    /**
     해당 Key의 트리데이터 리턴
     */
    func getTreeData(key: UUID) -> [TreeModel] {
        guard var subTreeData = self.treeData[key] else {
            print("Can't find data with key!")
            let subTreeData = [TreeModel]()
            self.treeData.updateValue(subTreeData, forKey: key)
            return subTreeData
        }
            
        subTreeData.append(self.getPlusTreeModel(key: key, index: subTreeData.count))
        return subTreeData
    }
    
    func selectTreeHierarchy(index: Int) {
        let removeCount = self.treeHierarchy.count - (index + 1)
        self.treeHierarchy.removeLast(removeCount)
    }
    
    func getPlusTreeModel(key: UUID, index: Int) -> TreeModel {
        return TreeModel(title: "New", value: .new, key: key, index: index)
    }
}
