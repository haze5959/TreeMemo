//
//  TreeMemoViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/28.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

class TreeMemoViewModel {
    /**
     해당 Key의 트리데이터 리턴
     */
    func getTreeData(key: Double) -> [TreeModel] {
        if let rootData = TreeMemoState.shared.treeData[key] {
            return rootData
        } else {
            //첫 구동
            var treeData = [Double : [TreeModel]]()
            let rootData = [TreeModel(title: "New")]
            treeData.updateValue(rootData, forKey: key)
            
            TreeMemoState.shared.treeData = treeData
            return rootData
        }
    }
    
    func selectTreeHierarchy(index: Int) {
        let removeCount = TreeMemoState.shared.treeHierarchy.count - (index + 1)
        TreeMemoState.shared.treeHierarchy.removeLast(removeCount)
    }
}
