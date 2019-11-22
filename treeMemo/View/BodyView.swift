//
//  BodyView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct BodyView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            OpenedNode {
                print("click1")
                self.body.
            }
            ClosedNode {
                print("click2")
            }
        }
    }
}

// MARK: Preview
struct Body_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            BodyView()
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
