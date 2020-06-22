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
    #if !os(macOS)
    let wcSession = TreeMemoWCSession()
    #endif
    
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
    
    #if os(iOS)
    let treeStore = CloudManager.shared.store
    
    init() {
        self.cancellable = self.$treeData
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink(receiveValue: { (treeData) in
                if self.notSaveOnce {
                    self.notSaveOnce = false
                    return
                }
                
                print("데이터 저장!")
                self.saveTreeData(treeData)
                // Watch <-> Phone Data sharing
                self.wcSession.sendTreeData(data: self.getData(treeData: treeData))
            })
    }
    #elseif os(macOS)
    let treeStore = CloudManager.shared.store
    
    init() {
        self.cancellable = self.$treeData
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink(receiveValue: { (treeData) in
                if self.notSaveOnce {
                    self.notSaveOnce = false
                    return
                }
                
                print("데이터 저장!")
                self.saveTreeData(treeData)
            })
    }
    #else
    let treeStore = UserDefaults.init()
    
    init() {
        self.cancellable = self.$treeData
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink(receiveValue: { (treeData) in
                if self.notSaveOnce {
                    self.notSaveOnce = false
                    return
                }
                
                if self.wcSession.isParingSuccess {
                    print("데이터 저장!")
                    
                    // Watch <-> Phone Data sharing
                    self.wcSession.sendTreeData(data: self.getData(treeData: treeData)) { (isSuccess) in
                        if isSuccess {
                            self.saveTreeData(treeData)
                        } else {
                            WatchAlertState.shared.show(showCase: .notPared)
                        }
                    }
                } else {
                    self.wcSession.requestTreeData()
                }
            })
    }
    #endif
    
    // MARK: 트리데이터 초기화
    func initTreeData() {
        #if os(iOS) || os(macOS)
        if let data = self.treeStore.data(forKey: self.storedDataKey),
            let treeData = try? PropertyListDecoder().decode(TreeDataType.self, from: data) {
            
            self.updateTreeDataWithNotSave(treeData: treeData)
        } else {
            //페이지 첫 진입
            var treeData = TreeDataType()
            let rootData = [TreeModel]()
            
            treeData.updateValue(rootData, forKey: RootKey)
            self.treeData = treeData
            self.updateTreeDataWithNotSave(treeData: treeData)
        }
        #else
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.notSaveOnce = true
            self.wcSession.requestTreeData()
        }
        #endif
    }
    
    func saveTreeData(_ value: TreeDataType) {
        guard let encodedTreeData = try? PropertyListEncoder().encode(value) else {
            print("save encoding fail!")
            return
        }
        
        self.treeStore.set(encodedTreeData, forKey: self.storedDataKey)
        UserDefaults(suiteName: "group.oq.treememo")?.set(encodedTreeData, forKey: "RootTreeData")
    }
    
    #if os(iOS) && !TODAY_EXTENTION
    func removeAllTreeData() {
        PinWheelView.shared.showProgressView()
        CloudManager.shared.deleteData(recordType: "Image")
        CloudManager.shared.deleteData(recordType: "Text")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            PinWheelView.shared.hideProgressView()
            self.treeStore.removeObject(forKey: self.storedDataKey)
            self.initTreeData()
            self.wcSession.sendTreeData(data: self.getData(treeData: self.treeData))
            
            UserDefaults(suiteName: "group.oq.treememo")?.removeObject(forKey: "RootTreeData")
        }
    }
    #endif
    
    func updateTreeDataWithNotSave(treeData: TreeDataType) {
        DispatchQueue.main.async {
            self.notSaveOnce = true
            self.treeData = treeData
        }
    }
    
    /**
     해당 Key의 트리데이터 리턴
     */
    func getTreeData(key: UUID, isEditMode: Bool = false) -> [TreeModel] {
        guard var subTreeData = self.treeData[key] else {
            print("Can't find data with key!")
            #if os(iOS) || os(macOS)
            let subTreeData = [TreeModel]()
            self.treeData.updateValue(subTreeData, forKey: key)
            return subTreeData
            #else
            WatchAlertState.shared.show(showCase: .notPared)
            return [TreeModel]()
            #endif
        }
        
        if !isEditMode || subTreeData.count == 0 {
            subTreeData.append(self.getPlusTreeModel(key: key, index: subTreeData.count))
        }
        
        return subTreeData
    }
    
    #if os(iOS) || os(macOS)
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
        case .image(let recordName):
            CloudManager.shared.deleteData(recordType: "Image", recordName: recordName)
        case .longText(let recordName):
            CloudManager.shared.deleteData(recordType: "Text", recordName: recordName)
        default:
            break
        }
    }
    #endif
    
    func moveTreeData(key: UUID, indexSet: IndexSet, to destination: Int) {
        guard var subTreeData = self.treeData[key] else {
            print("Can't find data with key!")
            return
        }
        
        let pastIndex = indexSet.last! as Int
        var nowIndex = destination
        if destination > pastIndex {
            nowIndex -= 1
        }
        
        let tempData = subTreeData.remove(at: pastIndex)
        subTreeData.insert(tempData, at: nowIndex)
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
    
    func getData(treeData: TreeDataType) -> Data {
        guard let jsonData = try? JSONEncoder().encode(treeData) else {
            print("treeData could not encoding!")
            return Data()
        }
        
        return jsonData
    }
}
