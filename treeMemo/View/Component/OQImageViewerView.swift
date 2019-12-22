//
//  OQImageViewerView.swift
//  treeMemo
//
//  Created by OQ on 2019/12/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct OQImageViewerView: View {
    let image: Image
    @State var lastScaleValue: CGFloat = 1.0
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            self.image
        }.gesture(MagnificationGesture().onChanged { val in
                    let delta = val / self.lastScaleValue
                    self.lastScaleValue = val
                    let newScale = self.scale * delta

        //... anything else e.g. clamping the newScale
        }.onEnded { val in
          // without this the next gesture will be broken
          self.lastScaleValue = 1.0
        }
    }
}

struct OQImageViewerView_Previews: PreviewProvider {
    static var previews: some View {
        OQImageViewerView(image: Image(systemName: "photo"))
    }
}
