//
//  TreeViewModel.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/20.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import Foundation

let RootKey = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

let DateTypeDDay = 4
let DateTypeDDayIncludeFirstDay = 5
struct TreeDateType: Codable {
    let date: Date
    let type: Int   //UIDatePicker.Mode로 파싱하는게 필요
}

enum TreeValueType: Codable {
    case new    //새로 만들기 버튼
    case none   //설정 안된 초기 셀
    case child(key: UUID)
    case text(val: String)
    case longText(recordName: String)
    case int(val: Int)
    case date(val: TreeDateType)
    case toggle(val: Bool)
    case image(recordName: String)
    case link(val: String)
    
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
        case link
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
            self = .longText(recordName: value)
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
            self = .image(recordName: value)
            return
        } else if let value = try? values.decode(String.self, forKey: .link) {
            self = .link(val: value)
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
        case .link(let val):
            try container.encode(val, forKey: .link)
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
    var index: Int
}
