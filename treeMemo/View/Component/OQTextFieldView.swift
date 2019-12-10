//
//  OQTextFieldView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/12/09.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct OQTextFieldView: View {
    @State var text: String
    let textChangedHandler: (String) -> Void
    
    var body: some View {
        TextField(self.text, text: self.$text) {
            self.textChangedHandler(self.text)
        }
        .multilineTextAlignment(.trailing)
        .padding()
    }
}

struct OQTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        OQTextFieldView(text: "테스트 입니다.", textChangedHandler: {(text) in
            print(text)
        })
    }
}
