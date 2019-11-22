//
//  ContentView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/19.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            VStack {
                //해더
                HeaderView()
                
                //스페이서
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([
            "iPhone SE",
//            "iPhone XS Max"
        ], id: \.self) { deviceName in
            ContentView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
        }
    }
}
