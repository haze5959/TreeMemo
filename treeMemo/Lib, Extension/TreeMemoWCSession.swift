//
//  TreeMemoWCSession.swift
//  treeMemo
//
//  Created by OGyu kwon on 2020/02/19.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import Foundation
import WatchConnectivity

class TreeMemoWCSession: NSObject, WCSessionDelegate {
    var wcSession = WCSession.default
    
    override init() {
        super.init()
        self.wcSession.delegate = self
        self.wcSession.activate()
    }
    
    func sendTreeData(treeData: TreeDataType) {
        self.wcSession.sendMessageData(self.getData(treeData: treeData),
                                       replyHandler: nil) { (error) in
                                        print("wcSession message error: \(error)")
        }
    }
    
    func getData(treeData: TreeDataType) -> Data {
        guard let jsonData = try? JSONEncoder().encode(treeData) else {
            print("treeData could not encoding!")
            return Data()
        }

        return jsonData
    }
    
    func decodeData(data: Data) -> TreeDataType {
        guard let treeData = try? JSONDecoder().decode(TreeDataType.self, from: data) else {
            print("treeData could not decoding!")
            return TreeDataType()
        }
        
        return treeData
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch activationState: \(activationState)")
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch sessionDidDeactivate: \(session)")
    }
#endif

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        DispatchQueue.main.async {
            let treeData = self.decodeData(data: messageData)
            TreeMemoState.shared.saveTreeData(treeData) // 클라우드 업데이트를 안하기 위함
            TreeMemoState.shared.updateTreeDataWithNotSave(treeData: treeData)
        }
    }
}
