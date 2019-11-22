//
//  HeaderView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            //설정 버튼
            Button(action: {
                
            }, label: {
                Image(systemName: "gear")
                    .imageScale(.large)
                    .padding()
            })
            
            //스페이서
            Spacer()
            
            //타이틀
            Text("title")
            
            //스페이서
            Spacer()
            
            //데이터 업데이트 버튼
            Button(action: {
                
            }, label: {
                Image(systemName: "arrow.2.circlepath")
                    .imageScale(.large)
                    .padding()
            })
        }
    }
}

// MARK: Preview
struct Header_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            HeaderView()
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
