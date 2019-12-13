//
//  TreeViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/20.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit

var RootKey: UUID {
    if let rootKeyString = UserDefaults().object(forKey: "rootKey") as? String,
        let rootKey = UUID(uuidString: rootKeyString) {
        return rootKey
    } else {
        let rootKey = UUID()
        UserDefaults().set(rootKey.uuidString, forKey: "rootKey")
        return rootKey
    }
}

struct TreeDateType: Codable {
    let date: Date
    let type: Int   //UIDatePicker.Mode로 파싱하는게 필요
}

enum TreeValueType: Codable {
    case new    //새로 만들기 버튼
    case none   //설정 안된 초기 셀
    case child(key: UUID)
    case text(val: String)
    case longText(val: String)
    case int(val: Int)
    case date(val: TreeDateType)
    case toggle(val: Bool)
    case image(imagePath: String)
    
    private enum CodingKeys: String, CodingKey {
        case new
        case none
        case child
        case text
        case longText
        case int
        case date
        case toggle
        case image
    }
    
    enum TreeValueTypeCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? values.decodeNil(forKey: .new) {
            self = .new
            return
        } else if let _ = try? values.decodeNil(forKey: .none) {
            self = .none
            return
        } else if let value = try? values.decode(UUID.self, forKey: .child) {
            self = .child(key: value)
            return
        } else if let value = try? values.decode(String.self, forKey: .text) {
            self = .text(val: value)
            return
        } else if let value = try? values.decode(String.self, forKey: .longText) {
            self = .longText(val: value)
            return
        } else if let value = try? values.decode(Int.self, forKey: .int) {
            self = .int(val: value)
            return
        } else if let value = try? values.decode(TreeDateType.self, forKey: .date) {
            self = .date(val: value)
            return
        } else if let value = try? values.decode(Bool.self, forKey: .toggle) {
            self = .toggle(val: value)
            return
        } else if let value = try? values.decode(String.self, forKey: .image) {
            self = .image(imagePath: value)
            return
        }
        
        throw TreeValueTypeCodingError.decoding("Whoops! \(dump(values))")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .new:
            try container.encodeNil(forKey: .new)
        case .none:
            try container.encodeNil(forKey: .none)
        case .child(let val):
            try container.encode(val, forKey: .child)
        case .text(let val):
            try container.encode(val, forKey: .text)
        case .longText(let val):
            try container.encode(val, forKey: .longText)
        case .int(let val):
            try container.encode(val, forKey: .int)
        case .date(let val):
            try container.encode(val, forKey: .date)
        case .toggle(let val):
            try container.encode(val, forKey: .toggle)
        case .image(let imageData):
            try container.encode(imageData, forKey: .image)
        }
    }
}

/**
 트리뷰 모델
 */
struct TreeModel: Codable, Identifiable {
    let id = UUID()
    
    var title: String
    var value: TreeValueType = .none
    
    let key: UUID //TreeData에서 찾을 key값
    let index: Int
}

// MARK: 목업
var mockUpVal: TreeDataType {
    var mockUp = TreeDataType()
    var root = TreeModel(title: "테스트용 루트뷰", key:RootKey, index: 0)
    let depth0Key = UUID()
    root.value = .child(key: depth0Key)
    
    var child1Depth1 = TreeModel(title: "아들1", key:depth0Key, index: 0)
    let depth1Key = UUID()
    child1Depth1.value = .child(key: depth1Key)
    
    var child2Depth1 = TreeModel(title: "아들2", key:depth0Key, index: 1)
    child2Depth1.value = .int(val: 3)
    
    var child1Depth2 = TreeModel(title: "손자1", key:depth1Key, index: 0)
    let depth2Key = UUID()
    child1Depth2.value = .child(key: depth2Key)
    
    var child1Depth3 = TreeModel(title: "아기1", key:depth2Key, index: 1)
    child1Depth3.value = .text(val: "으앵으양")
    
    var child2Depth3 = TreeModel(title: "아기2", key:depth2Key, index: 0)
    let depth3Key = UUID()
    child2Depth3.value = .child(key: depth3Key)
    
    var child1Depth4 = TreeModel(title: "어디까지 갈거냐", key:depth3Key, index: 0)
    let depth4Key = UUID()
    child1Depth4.value = .child(key: depth4Key)
    
    let child1Depth5 = TreeModel(title: "그만안~~~", key:depth4Key, index: 0)
    
    mockUp.updateValue([root], forKey: RootKey)
    
    let depth1 = [child1Depth1, child2Depth1]
    mockUp.updateValue(depth1, forKey: depth0Key)
    
    let depth2 = [child1Depth2]
    mockUp.updateValue(depth2, forKey: depth1Key)
    
    let depth3 = [child1Depth3, child2Depth3]
    mockUp.updateValue(depth3, forKey: depth2Key)
    
    let depth4 = [child1Depth4]
    mockUp.updateValue(depth4, forKey: depth3Key)
    
    let depth5 = [child1Depth5]
    mockUp.updateValue(depth5, forKey: depth4Key)
    
    return mockUp
}
