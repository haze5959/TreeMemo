//
//  TreeNodeView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/21.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

class BorderedButton: UIButton {
    var cornerRadius: CGFloat = 50
    var borderWidth: CGFloat = 200
    var borderColor: UIColor? = .blue
}

class OpenedNode: BorderedButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTitle("opened", for: .normal)
        self.tintColor = .systemOrange
        self.setTitleColor(.systemOrange, for: .normal)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}

class ClosedNode: BorderedButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTitle("closed", for: .normal)
        self.tintColor = .systemOrange
        self.setTitleColor(.systemOrange, for: .normal)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}

// MARK: Preview
struct TreeNode_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            UIViewPreview {
                return OpenedNode(frame: .zero)
            }
            
            UIViewPreview {
                return ClosedNode(frame: .zero)
            }
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
