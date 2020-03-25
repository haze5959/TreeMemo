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
    
    func sendTreeData(data: Data, completion: ((Bool) -> Void)? = nil) {
        if self.wcSession.isReachable {
            self.wcSession.sendMessageData(data,
                                           replyHandler: nil) { (error) in
                                            print("wcSession message error: \(error)")
                                            completion?(false)
            }
        } else {
            print("WCSession not reachable")
            completion?(false)
        }
    }
    
    #if os(watchOS)
    func requestTreeData() {
        if self.wcSession.isReachable {
            self.wcSession.sendMessage(["request": true],
                                       replyHandler: { (result) in
                                        if let treeData = result["data"] as? Data {
                                            let treeModel = self.decodeData(data: treeData)
                                            TreeMemoState.shared.saveTreeData(treeModel)
                                            TreeMemoState.shared.updateTreeDataWithNotSave(treeData: treeModel)
                                        } else {
                                            print("wcSession message error: type dismatch")
                                            WatchAlertState.shared.show(showCase: .notPared)
                                        }
            }) { (error) in
                print("wcSession message error: \(error)")
                WatchAlertState.shared.show(showCase: .notPared)
            }
        } else {
            print("WCSession not reachable")
            WatchAlertState.shared.show(showCase: .notPared)
        }
    }
    #endif
    
    func decodeData(data: Data) -> TreeDataType {
        guard let treeData = try? JSONDecoder().decode(TreeDataType.self, from: data) else {
            print("treeData could not decoding!")
            return TreeDataType()
        }
        
        return treeData
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("Watch activationState: activated")
        case .inactive:
            print("Watch activationState: inactive")
        case .notActivated:
            print("Watch activationState: notActivated")
        }
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
            TreeMemoState.shared.saveTreeData(treeData)
            TreeMemoState.shared.updateTreeDataWithNotSave(treeData: treeData)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let isRequest = message["request"] as? Bool {
            if isRequest {
                let state = TreeMemoState.shared
                replyHandler(["data": state.getData(treeData: state.treeData)])
            }
        }
    }
}
