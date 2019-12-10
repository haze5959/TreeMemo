////
////  OQIntFieldView.swift
////  treeMemo
////
////  Created by OGyu kwon on 2019/12/10.
////  Copyright © 2019 OGyu kwon. All rights reserved.
////
//
//import SwiftUI
//
//struct OQIntFieldView: View {
//    @State var value: Int
//    let valueChangedHandler: (Int) -> Void
//    
//    var body: some View {
//        TextField(self.value, text: self.$value) {
//            self.valueChangedHandler(self.value)
//        }
//        .multilineTextAlignment(.trailing)
//        .padding()
//    }
//}
//
//struct OQIntFieldView_Previews: PreviewProvider {
//    static var previews: some View {
//        OQTextFieldView(text: "테스트 입니다.", textChangedHandler: {(text) in
//            print(text)
//        })
//    }
//}
