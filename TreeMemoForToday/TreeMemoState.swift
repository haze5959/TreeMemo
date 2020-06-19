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
            let treeData = try? PropertyListDecoder().decode([TreeModel].self, from: data) {
            self.treeData = [RootKey: treeData]
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
    func getTreeData(key: UUID, isEditMode: Bool = false) -> [TreeModel] {
        guard let subTreeData = self.treeData[key] else {
            print("Can't find data with key!")
            let subTreeData = [TreeModel]()
            self.treeData.updateValue(subTreeData, forKey: key)
            return subTreeData
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
    
    func selectTreeHierarchy(index: Int) {
        print("today ext is not support.")
    }
}
