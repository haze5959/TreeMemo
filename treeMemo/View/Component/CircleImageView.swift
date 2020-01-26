//
//  CircleImageView.swift
//  treeMemo
//
//  Created by OQ on 2020/01/26.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//
import SwiftUI

struct CircleImageView: View {
    var image: Image
    
    var body: some View {
        image
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
    }
}

struct CircleImageView_Preview: PreviewProvider {
    static var previews: some View {
        CircleImageView(image: Image(systemName: "floder"))
    }
}
