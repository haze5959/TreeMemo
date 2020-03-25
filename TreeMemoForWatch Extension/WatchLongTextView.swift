//
//  WatchLongTextView.swift
//  TreeMemoForWatch Extension
//
//  Created by OGyu kwon on 2020/03/17.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI
import CloudKit

struct WatchLongTextView: View {
    let title: String
    let recordName: String
    
    @State private var text: String = "Loading..."
    
    var body: some View {
        ScrollView(.vertical) {
            Text(self.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .center)
        }.navigationBarTitle(self.title)
            .onAppear {
                self.getTextData(recordName: self.recordName) { (result) in
                    switch result {
                    case .success(let longText):
                        self.text = longText
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.text = error.localizedDescription
                    }
                }
        }
    }
    
    func getTextData(recordName: String, completion: @escaping (_ result: Result<String, Error>) -> Void) {
        //iCloud 권한 체크
        CKContainer.default().accountStatus { status, error in
            guard status == .available else {
                print(status)
                return
            }
            
            //The user’s iCloud account is available..
            let container = CKContainer.init(identifier: "iCloud.com.oq.treememo")
            let privateDB = container.privateCloudDatabase
            
            let recordID = CKRecord(recordType: "Text", recordID: .init(recordName: recordName))
            let predicate = NSPredicate(format: "recordID = %@", recordID)
            
            let query = CKQuery(recordType: "Text", predicate: predicate)
            
            privateDB.perform(query, inZoneWith: nil) { records, error in
                guard error == nil else {
                    print("err: \(String(describing: error))")
                    completion(.failure(error!))
                    return
                }
                
                guard let records = records else {
                    print("records is nil")
                    return
                }
                
                guard let text = records[0].value(forKey: "text") as? String else {
                    print("text is nil")
                    return
                }
                
                completion(.success(text))
            }
        }
    }
}

struct WatchLongTextView_Previews: PreviewProvider {
    static var previews: some View {
        WatchLongTextView(title: "test1", recordName: "test2")
    }
}
