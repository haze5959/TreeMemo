//
//  TreeViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/20.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import Foundation

let RootKey: Double = 0

enum TreeValueType: Codable {
    case none
    case child(key: Double)
    case text(val: String)
    case longText(val: String)
    case int(val: Int)
    case date(val: Date)
    case toggle(val: Bool)

    private enum CodingKeys: String, CodingKey {
        case none
        case child
        case text
        case longText
        case int
        case date
        case toggle
    }
    
    enum TreeValueTypeCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? values.decodeNil(forKey: .none) {
            self = .none
            return
        } else if let value = try? values.decode(Double.self, forKey: .child) {
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
        } else if let value = try? values.decode(Date.self, forKey: .date) {
            self = .date(val: value)
            return
        } else if let value = try? values.decode(Bool.self, forKey: .toggle) {
            self = .toggle(val: value)
            return
        }
        
        throw TreeValueTypeCodingError.decoding("Whoops! \(dump(values))")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
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
    var index = 0   //정렬 순서
}

// MARK: 목업
var mockUpVal: [Double: [TreeModel]] {
    var mockUp = [Double: [TreeModel]]()
    var root = TreeModel(title: "테스트용 루트뷰")
    
    var child1Depth1 = TreeModel(title: "아들1")
    
    var child2Depth1 = TreeModel(title: "아들2")
    child2Depth1.value = .int(val: 3)
    
    var child1Depth2 = TreeModel(title: "손자1")
    
    var child1Depth3 = TreeModel(title: "아기1")
    child1Depth3.value = .text(val: "으앵으양")
    
    var child2Depth3 = TreeModel(title: "아기2")
    
    var child1Depth4 = TreeModel(title: "어디까지 갈거냐")
    
    let child1Depth5 = TreeModel(title: "그만안~~~")
    
    let timeStamp = Date().timeIntervalSinceNow
    
    root.value = .child(key: timeStamp + 1)
    child1Depth1.value = .child(key: timeStamp + 2)
    child1Depth2.value = .child(key: timeStamp + 3)
    child2Depth3.value = .child(key: timeStamp + 4)
    child1Depth4.value = .child(key: timeStamp + 5)
    
    mockUp.updateValue([root], forKey: RootKey)
    
    let depth1 = [child1Depth1, child2Depth1]
    mockUp.updateValue(depth1, forKey: timeStamp + 1)
    
    let depth2 = [child1Depth2]
    mockUp.updateValue(depth2, forKey: timeStamp + 2)
    
    let depth3 = [child1Depth3, child2Depth3]
    mockUp.updateValue(depth3, forKey: timeStamp + 3)
    
    let depth4 = [child1Depth4]
    mockUp.updateValue(depth4, forKey: timeStamp + 4)
    
    let depth5 = [child1Depth5]
    mockUp.updateValue(depth5, forKey: timeStamp + 5)
    
    return mockUp
}
