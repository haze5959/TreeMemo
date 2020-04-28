//
//  macOS+Extension.swift
//  TreeMemoForMac
//
//  Created by OGyu kwon on 2020/04/10.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI
import Cocoa

struct Image: View {
    enum Scale {
        case small
        case medium
        case large
    }
    
    let symbol: String
    
    init(systemName: String) {
        self.symbol = [
            "folder": "📁",
            "plus.circle": "➕",
            "plus.square": "➕",
            "doc.plaintext": "📄",
            "link": "🔗",
            "gear": "기어",
            "list.number": "𝌡",
            "house": "🏠",
            "chevron.compact.right": ">",
            "chevron.left": "<",
            "pencil": "연필",
            "rosette": "훈장",
            "cart": "카트",
            "trash": "쓰래기통",
            "hand.thumbsup": "엄치척",
            "photo": "사진",
            "icloud.and.arrow.down": "클라우드"
            ][systemName] ?? "???"
    }
    
    var body: some View {
        Text(self.symbol)
    }
}

extension NSColor {
    public static let label = { () -> NSColor in
        if NSApp.effectiveAppearance.name == .darkAqua {
            return NSColor.white
        } else {
            return NSColor.black
        }
    }()
    
    public static let systemBackground = { () -> NSColor in
        if NSApp.effectiveAppearance.name == .darkAqua {
            return NSColor.black
        } else {
            return NSColor.white
        }
    }()
}



extension View {
    func imageScale(_ scale: Image.Scale) -> some View {
        // 맥은 이미지 스케일 지원 안함
        return self
    }
}

extension NSView {
    var isDarkMode: Bool {
        if effectiveAppearance.name == .darkAqua {
            return true
        }
        
        return false
    }
}
