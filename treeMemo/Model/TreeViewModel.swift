//
//  TreeViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/20.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import Foundation

enum TreeValueType: Codable {
    case string(val: String)
    case int(val: Int)
    case date(val: Date)

    private enum CodingKeys: String, CodingKey {
        case string
        case int
        case date
    }
    
    enum TreeValueTypeCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? values.decode(String.self, forKey: .string) {
            self = .string(val: value)
            return
        } else if let value = try? values.decode(Int.self, forKey: .int) {
            self = .int(val: value)
            return
        } else if let value = try? values.decode(Date.self, forKey: .date) {
            self = .date(val: value)
            return
        }
        
        throw TreeValueTypeCodingError.decoding("Whoops! \(dump(values))")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let val):
            try container.encode(val, forKey: .string)
        case .int(let val):
            try container.encode(val, forKey: .int)
        case .date(let val):
            try container.encode(val, forKey: .date)
        }
    }
}

/**
 트리뷰 모델
 */
class TreeModel: Codable {
    var childTrees = [TreeModel]()
    var keyStr = ""
    var valueStr: TreeValueType?
    var index = 0   //정렬 순서
}

class RootTreeModel: TreeModel {
}

class ChildTreeModel: TreeModel {
    let parentTree: TreeModel
    
    init(parentTree: TreeModel) {
        self.parentTree = parentTree
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
