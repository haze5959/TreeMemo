//
//  WatchInputNumberView.swift
//  TreeMemoForWatch Extension
//
//  Created by OGyu kwon on 2020/02/28.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI

struct WatchInputNumberView: View {
    @State var tempInt: Float
    var completeHandler: ((_ number: Int) -> Void)?
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack {
            Text("Please scroll the digital crown.")
            Spacer()
            Text("\(Int(self.tempInt))")
                .font(.largeTitle)
                .focusable(true)
                .digitalCrownRotation(self.$tempInt, from: .nan, through: .nan, sensitivity: .low)
            Spacer()
            Button(action: {
                self.completeHandler?(Int(self.tempInt))
                self.presentation.wrappedValue.dismiss()
            }, label: {
                Text("Done")
            })
        }
    }
}

struct WatchInputNumberView_Previews: PreviewProvider {
    static var previews: some View {
        WatchInputNumberView(tempInt: 0)
    }
}
