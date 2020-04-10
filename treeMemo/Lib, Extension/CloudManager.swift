//
//  CloudManager.swift
//  treeMemo
//
//  Created by OGyu kwon on 2020/03/13.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

#if os(iOS)
import UIKit
#endif
import Foundation
import CloudKit

enum CMError: Error {
    case msg(_ string: String)
}

class CloudManager {
    static let shared = CloudManager()
    
    let icloudNotUseMsg = "user’s iCloud is not available.\nThis might happen if the user is not logged into iCloud or not Setting on iCloud.\n\nGo to Settings, tap [your name], then select iCloud and please set up iCloud."
    let icloudFailMsg = "This might happen if the user is not logged into iCloud or not Setting on iCloud.\n\nGo to Settings, tap [your name], then select iCloud and please set up iCloud."
    
    var container: CKContainer!
    var privateDB: CKDatabase!
    
    let store = NSUbiquitousKeyValueStore.default
    
    init() {
        self.initIcloud()
    }
    
    func initIcloud() {
        //iCloud 권한 체크
        CKContainer.default().accountStatus { status, error in
            guard status == .available else {
                self.alertPopUp(bodyStr: self.icloudNotUseMsg)
                return
            }
            
            //The user’s iCloud account is available..
            self.container = CKContainer.init(identifier: "iCloud.com.oq.treememo")
            self.privateDB = self.container.privateCloudDatabase
            
            NotificationCenter
                .default
                .addObserver(self, selector: #selector(self.ubiquitousKeyValueStoreDidChange),
                             name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                             object: self.store)
        }
    }
    
    func getData(recordType: String, recordName: String? = nil, completion: @escaping (_ result: Result<[CKRecord], CMError>) -> Void) {
        PinWheelView.shared.showProgressView()
        
        var predicate = NSPredicate(value: true)
        if let recordName = recordName {
            let recordID = CKRecord(recordType: recordType, recordID: .init(recordName: recordName))
            predicate = NSPredicate(format: "recordID = %@", recordID)
        }
        
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        self.privateDB.perform(query, inZoneWith: nil) { records, error in
            PinWheelView.shared.hideProgressView()
            guard error == nil else {
                print("err: \(String(describing: error))")
                self.alertPopUp(bodyStr: self.icloudFailMsg)
                completion(.failure(.msg(self.icloudFailMsg)))
                return
            }
            
            guard let records = records else {
                print("records is nil")
                completion(.failure(.msg(self.icloudFailMsg)))
                return
            }
            
            completion(.success(records))
        }
    }
    
    func makeData(record: CKRecord, completion: @escaping (_ result: Result<CKRecord, CMError>) -> Void) {
        PinWheelView.shared.showProgressView()
        
        self.privateDB.save(record) { savedRecord, error in
            PinWheelView.shared.hideProgressView()
            guard error == nil else {
                print("err: \(String(describing: error))")
                self.alertPopUp(bodyStr: self.icloudFailMsg)
                completion(.failure(.msg(self.icloudFailMsg)))
                return
            }
            
            guard let record = savedRecord else {
                print("record is nil")
                completion(.failure(.msg(self.icloudFailMsg)))
                return
            }
            
            completion(.success(record))
        }
    }
    
    func updateData(recordName: String, key: String, value: CKRecordValue, completion: @escaping (_ result: Result<(), CMError>) -> Void) {
        PinWheelView.shared.showProgressView()
        
        let recordId = CKRecord.ID(recordName: recordName)
        self.privateDB.fetch(withRecordID: recordId) { updatedRecord, error in
            PinWheelView.shared.hideProgressView()
            guard error == nil else {
                print("err: \(String(describing: error))")
                self.alertPopUp(bodyStr: self.icloudFailMsg)
                completion(.failure(.msg(self.icloudFailMsg)))
                return
            }
            
            guard let record = updatedRecord else {
                print("record is nil")
                completion(.failure(.msg(self.icloudFailMsg)))
                return
            }
            
            record.setObject(value, forKey: key)
            
            DispatchQueue.main.async {
                self.privateDB.save(record) { savedRecord, error in
                    guard error == nil else {
                        print("err: \(String(describing: error))")
                        self.alertPopUp(bodyStr: self.icloudFailMsg)
                        completion(.failure(.msg(self.icloudFailMsg)))
                        return
                    }
                    
                    completion(.success(()))
                }
            }
        }
    }
    
    func deleteData(recordType: String, recordName: String? = nil) {
        var predicate = NSPredicate(value: true)
        if let recordName = recordName {
            let recordID = CKRecord(recordType: recordType, recordID: .init(recordName: recordName))
            predicate = NSPredicate(format: "recordID = %@", recordID)
        }
        
        let query = CKQuery(recordType: recordType, predicate: predicate)
        self.privateDB.perform(query, inZoneWith: nil) { records, error in
            guard error == nil else {
                print("err: \(String(describing: error))")
                self.alertPopUp(bodyStr: self.icloudFailMsg)
                return
            }
        }
    }
    
    #if os(macOS)
    func alertPopUp(bodyStr:String) {
        // TODO: 얼럿
    }
    #else
    func alertPopUp(bodyStr:String) {
        DispatchQueue.main.async {
            guard let rootVC = UIApplication.shared.windows[0].rootViewController else {
                print("rootViewController not found.")
                return
            }
            
            let alert = UIAlertController(title: "Notice", message: bodyStr, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Reload iCloud", style: .cancel, handler: { action in
                self.initIcloud()
            }))
            
            rootVC.present(alert, animated: true)
        }
    }
    #endif
    
    @objc public func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        TreeMemoState.shared.initTreeData()
    }
}
