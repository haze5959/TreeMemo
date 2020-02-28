//
//  WatchInputFieldView.swift
//  TreeMemoForWatch Extension
//
//  Created by OGyu kwon on 2020/02/28.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import SwiftUI

struct WatchInputFieldView: View {
    @State var tempText = ""
    var completeHandler: ((_ text: String) -> Void)?
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        TextField("Input memo title.",
                               text: self.$tempText,
                               onEditingChanged: { _ in },
                               onCommit: {
                                self.completeHandler?(self.tempText)
                                self.presentation.wrappedValue.dismiss()
        })
    }
}

struct WatchInputFieldView_Previews: PreviewProvider {
    static var previews: some View {
        WatchInputFieldView()
    }
}
